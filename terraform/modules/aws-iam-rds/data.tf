data "aws_iam_policy_document" "access" {
  count = var.create ? 1 : 0

  statement {
    sid    = "GetMetadata"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AutoEnableDatabaseIAMAuth"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:ModifyDBInstance",
      "rds:ModifyDBCluster",
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
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AutoEnableDatabaseIAMAuth"
    effect = "Allow"
    actions = [
      "rds:ModifyDBInstance",
      "rds:ModifyDBCluster",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DatabaseIAMAuth"
    effect = "Allow"
    actions = [
      "rds-db:connect",
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
    sid    = "AutoEnableDatabaseIAMAuth"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
    ]
    resources = ["*"]
  }
}
