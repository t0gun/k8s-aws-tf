
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    ManagedBy = "terraform"
    Scope     = "bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "retain-recent-state-versions"
    status = "Enabled"

    # Keep only recent noncurrent versions
    noncurrent_version_expiration {
      noncurrent_days           = 30 # delete version older than 30 days
      newer_noncurrent_versions = 20 # but always keep the 20 most recent
    }

    # clean up delete markers once there are no current versions at that key
    expiration {
      expired_object_delete_marker = true
    }

    # stop paying for orphaned multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

  }
}


# allow bucket owner own all objects
resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


data "aws_iam_policy_document" "state_bucket" {
  # Deny non-TLS
  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.state.arn, "${aws_s3_bucket.state.arn}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }



  # Deny uploads without SSE-S3
  statement {
    sid       = "DenyUnencryptedUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.state.arn}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "StringNotEquals"
      values   = ["AES256"]
      variable = "s3:x-amz-server-side-encryption"
    }
  }


  # Deny uploads when the SSE header is missing entirely
  statement {
    sid     = "DenyMissingSSEHeader"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.state.arn}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "Null"
      values   = ["true"]
      variable = "s3:x-amz-server-side-encryption"
    }
  }


}


resource "aws_s3_bucket_policy" "state" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.state_bucket.json
  depends_on = [
  aws_s3_bucket_public_access_block.state,
    aws_s3_bucket_ownership_controls.state
  ]
}


