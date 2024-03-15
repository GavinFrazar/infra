resource "aws_iam_policy" "access" {
  count = var.create ? 1 : 0

  name        = local.access_name
  path        = "/"
  description = "Teleport RDS database access"
  policy      = one(data.aws_iam_policy_document.access[*].json)
}

resource "aws_iam_policy" "access_boundary" {
  count = var.create ? 1 : 0

  name        = "${local.access_name}-boundary"
  path        = "/"
  description = "Teleport RDS database access"
  policy      = one(data.aws_iam_policy_document.access_boundary[*].json)
}

resource "aws_iam_policy" "discovery" {
  count = var.create ? 1 : 0

  name        = local.discovery_name
  path        = "/"
  description = "Teleport RDS database discovery"
  policy      = one(data.aws_iam_policy_document.discovery[*].json)
}

module "access" {
  create                   = var.create
  source                   = "../create-aws-iam-role"
  name                     = local.access_name
  description              = "Teleport RDS database access"
  permissions_boundary_arn = one(aws_iam_policy.access_boundary[*].arn)
  permissions_policy_arn   = one(aws_iam_policy.access[*].arn)
  trust_policy_principals  = var.trust_policy_principals
}

module "discovery" {
  create                  = var.create
  source                  = "../create-aws-iam-role"
  name                    = local.discovery_name
  description             = "Teleport RDS database discovery"
  permissions_policy_arn  = one(aws_iam_policy.discovery[*].arn)
  trust_policy_principals = var.trust_policy_principals
}
