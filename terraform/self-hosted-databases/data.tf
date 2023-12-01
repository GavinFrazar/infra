data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Defines a trust relationship policy that allows the EC2 Service
# to assume a given role.
data "aws_iam_policy_document" "allow_ec2_to_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "encryption_key_policy" {
  statement {
    sid    = "Allow root and Service users full control"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:root"
      ]
    }
    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }
}
