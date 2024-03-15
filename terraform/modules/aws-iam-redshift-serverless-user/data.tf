data "aws_iam_policy_document" "this" {
  count = var.create ? 1 : 0

  statement {
    sid    = "RedshiftServerlessAuthn"
    effect = "Allow"
    actions = [
      "redshift-serverless:GetCredentials",
    ]
    resources = var.workgroup_arns
  }
}
