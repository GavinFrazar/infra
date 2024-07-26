resource "aws_iam_policy" "this" {
  count = var.create ? 1 : 0

  name        = "${var.name_prefix}-permission-testing"
  path        = "/"
  description = "IAM role policy for misc testing purposes"
  policy      = file("${path.module}/permissions_policy.json")
}

module "this" {
  create                  = var.create
  source                  = "../create-aws-iam-role"
  name                    = "${var.name_prefix}-permission-tester"
  description             = "Using this role to quickly test misc permissions scenarios"
  permissions_policy_arn  = one(aws_iam_policy.this[*].arn)
  trust_policy_principals = var.trust_policy_principals
}
