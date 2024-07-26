resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  assume_role_policy   = one(data.aws_iam_policy_document.this[*].json)
  max_session_duration = 3600
  name                 = var.role_name
  tags                 = var.tags
}
