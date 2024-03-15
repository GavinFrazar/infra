data "aws_iam_policy_document" "access" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RedshiftMetadata"
    effect = "Allow"
    actions = [
      "redshift:DescribeClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamicDatabaseIAMAuth"
    effect = "Allow"
    actions = [
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
    ]
    resources = [local.access_role_arn]
  }
}

data "aws_iam_policy_document" "access_boundary" {
  count = var.create ? 1 : 0

  statement {
    sid    = "GetMetadata"
    effect = "Allow"
    actions = [
      "redshift:DescribeClusters",
      "redshift:GetClusterCredentials",
      "sts:AssumeRole",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DynamicDatabaseIAMAuth"
    effect = "Allow"
    actions = [
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
    ]
    resources = [local.access_role_arn]
  }
}

data "aws_iam_policy_document" "discovery" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RedshiftDiscovery"
    effect = "Allow"
    actions = [
      "redshift:DescribeClusters",
    ]
    resources = ["*"]
  }
}
