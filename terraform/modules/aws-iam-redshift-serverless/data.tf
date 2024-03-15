data "aws_iam_policy_document" "access" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RedshiftServerlessAccess"
    effect = "Allow"
    actions = [
      "redshift-serverless:GetEndpointAccess",
      "redshift-serverless:GetWorkgroup",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "discovery" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RedshiftServerlessDiscovery"
    effect = "Allow"
    actions = [
      "redshift-serverless:ListWorkgroups",
      "redshift-serverless:ListEndpointAccess",
      "redshift-serverless:ListTagsForResource",
    ]
    resources = ["*"]
  }
}
