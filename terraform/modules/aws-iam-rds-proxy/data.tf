data "aws_iam_policy_document" "access" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RDSProxyAccess"
    effect = "Allow"
    actions = [
      "rds:DescribeDBProxies",
      "rds:DescribeDBProxyEndpoints",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "discovery" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RDSProxyAccess"
    effect = "Allow"
    actions = [
      "rds:DescribeDBProxies",
      "rds:DescribeDBProxyEndpoints",
      "rds:ListTagsForResource",
    ]
    resources = ["*"]
  }
}
