resource "aws_iam_policy" "access" {
  count = var.create ? 1 : 0

  name        = local.access_name
  path        = "/"
  description = "IAM policy for Teleport database access"
  policy      = one(data.aws_iam_policy_document.access[*].json)
}

resource "aws_iam_policy" "discovery" {
  count = var.create ? 1 : 0

  name        = local.discovery_name
  path        = "/"
  description = "IAM policy for Teleport database discovery"
  policy      = one(data.aws_iam_policy_document.discovery[*].json)
}

module "access" {
  create                  = var.create
  source                  = "../create-aws-iam-role"
  name                    = local.access_name
  description             = "Teleport database access"
  permissions_policy_arn  = one(aws_iam_policy.access[*].arn)
  trust_policy_principals = var.trust_policy_principals
}

module "discovery" {
  create                  = var.create
  source                  = "../create-aws-iam-role"
  name                    = local.discovery_name
  description             = "Teleport database discovery"
  permissions_policy_arn  = one(aws_iam_policy.discovery[*].arn)
  trust_policy_principals = var.trust_policy_principals
}
