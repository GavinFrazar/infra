resource "aws_iam_policy" "gha_db_admin" {
  count = var.create ? 1 : 0

  name   = "ci-database-e2e-tests-db-admin-access"
  path   = "/"
  policy = data.aws_iam_policy_document.gha_db_admin[0].json
}

module "gha_db_admin" {
  source = "../create-aws-iam-role"

  create                  = var.create
  description             = "GHA db admin role"
  name                    = "ci-database-e2e-tests-db-admin-access"
  permissions_policy_arn  = one(aws_iam_policy.gha_db_admin[*].arn)
  trust_policy_principals = var.gha_db_admin_trusted_role_arns
}

module "databases_ci" {
  count  = var.create ? 1 : 0
  source = "/Users/gavin/code/cloud-terraform//aws/modules/databases-ci"

  # create                           = var.create
  name_prefix                      = "ci-database-e2e-tests"
  public_access_ip_ranges          = var.public_access_ip_ranges
  role_trust_policy_principal_arns = [module.gha_db_admin.role_arn]
  vpc_cidr                         = "10.0.0.0/20"
}
