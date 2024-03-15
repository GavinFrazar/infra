data "aws_caller_identity" "current" {
  count = var.create ? 1 : 0
}

data "aws_region" "current" {
  count = var.create ? 1 : 0
}

# Defines a trust relationship policy that allows the EC2 Service
# to assume a given role.
data "aws_iam_policy_document" "allow_ec2_to_assume_role" {
  count = var.create ? 1 : 0

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
  count = var.create ? 1 : 0

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
