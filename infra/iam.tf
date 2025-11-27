# the policy doesnt define what role can do just who can assume it
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals { # who is allowed to assume this role
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }

  }

}

data "aws_iam_policy_document" "ec2_ssm_send_command" {
  statement {
    sid    = "AllowSendCommandAWSRunShellScript"
    effect = "Allow"

    actions = [
      "ssm:SendCommand",
      "ssm:ListCommands",
      "ssm:ListCommandInvocations",
    ]

    # Limit to the AWS-RunShellScript document in your account and region
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:document/AWS-RunShellScript"
    ]

  }
}

resource "aws_iam_policy" "ec2_ssm_send_command" {
  name        = "k8s-ec2-ssm-send-command"
  description = "Allow EC2 nodes to call ssm:SendCommand for KTHW lab"
  policy      = data.aws_iam_policy_document.ec2_ssm_send_command.json
}


resource "aws_iam_role" "ec2" {
  name               = "k8s-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json

  tags = {
    ManagedBy = "terraform"
    Scope     = "identity"
  }
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "k8s-ec2-ssm-profile"
  role = aws_iam_role.ec2.name
  tags = {
    ManagedBy = "terraform"
    Scope     = "identity"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_send_command_attach" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_ssm_send_command.arn
}