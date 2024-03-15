resource "aws_iam_policy" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  path        = "/"
  description = "Redshift Serverless user auth"
  policy      = one(data.aws_iam_policy_document.this[*].json)
}

module "db_user" {
  create                  = var.create
  source                  = "../create-aws-iam-role"
  name                    = var.name
  description             = "Redshift Serverless database user"
  permissions_policy_arn  = one(aws_iam_policy.this[*].arn)
  trust_policy_principals = var.trust_policy_principals
}
