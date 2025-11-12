
data "aws_iam_openid_connect_provider" "github" {
  arn = "arn:aws:iam::555066115752:oidc-provider/token.actions.githubusercontent.com"
}


# Trust Policy relationships locking repo and branch
data "aws_iam_policy_document" "gha_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = [for r in var.allowed_refs : "repo:${var.github_repo}:ref:${r}"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

# role gha will assume which uses the trust policy we defined above
resource "aws_iam_role" "k8-aws-tf-apply" {
  name                 = "k8-aws-tf"
  assume_role_policy   = data.aws_iam_policy_document.gha_trust.json
  max_session_duration = 3600
  tags = {
    Managedby = "terraform"
    Scope     = "identity"
  }
}


# S3 Backend Access - prefix scoped includes .flock
data "aws_iam_policy_document" "state_access" {
  statement {
    sid       = "ListPrefixes"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket}"]
    condition {
      test     = "StringLike"
      values   = ["oidc/*", "prod/*"]
      variable = "s3:prefix"
    }


  }

  statement {
    sid     = "RWState"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "arn:aws:s3:::${var.state_bucket}/oidc/*",
      "arn:aws:s3:::${var.state_bucket}/prod/*",
    ]
  }

  statement {
    sid     = "RWLockfile"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]  # allows tf to delete lock in s3 successfully
    resources = [
      "arn:aws:s3:::${var.state_bucket}/oidc/*/*.tflock",
      "arn:aws:s3:::${var.state_bucket}/prod/*/*.tflock",
    ]
  }
}

resource "aws_iam_policy" "state_access" {
  name =  "${aws_iam_role.k8-aws-tf-apply.name}-state-access"
  policy = data.aws_iam_policy_document.state_access.json
}

resource "aws_iam_role_policy_attachment"  "attach_state-access" {
  role = aws_iam_role.k8-aws-tf-apply.name
  policy_arn = aws_iam_policy.state_access.arn
}



output "gha_role_arn" {
  value = aws_iam_role.k8-aws-tf-apply.arn
}


