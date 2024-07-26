resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  name                 = var.name
  assume_role_policy   = one(data.aws_iam_policy_document.trust[*].json)
  max_session_duration = 3600
  permissions_boundary = var.permissions_boundary_arn
}

resource "aws_iam_role_policy_attachment" "this" {
  count = var.create ? 1 : 0

  role       = one(aws_iam_role.this[*].name)
  policy_arn = var.permissions_policy_arn
}
