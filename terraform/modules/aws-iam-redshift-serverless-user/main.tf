resource "aws_iam_policy" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  path        = "/"
  description = "Redshift Serverless user auth"
  policy      = one(data.aws_iam_policy_document.this[*].json)
}

module "db_user" {
  source = "../create-aws-iam-role"

  create                  = var.create
  name                    = var.name
  description             = "Redshift Serverless database user"
  permission_policy_arns  = aws_iam_policy.this[*].arn
  trust_policy_principals = var.trust_policy_principals
}
