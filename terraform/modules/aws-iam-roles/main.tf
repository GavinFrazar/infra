resource "aws_iam_policy" "tester" {
  count = var.create ? 1 : 0

  name        = "${var.name_prefix}-permission-testing"
  path        = "/"
  description = "IAM role policy for misc testing purposes"
  policy      = file("${path.module}/permissions-tester-policy.json")
  tags        = var.tags
}

module "tester" {
  create                 = var.create
  source                 = "../create-aws-iam-role"
  name                   = "${var.name_prefix}-permission-tester"
  description            = "Using this role to quickly test misc permissions scenarios"
  permission_policy_arns = aws_iam_policy.tester[*].arn
  trust_policy_principals = concat(
    var.trust_policy_principals,
    # trust all of the integration roles for AWS console app integrations.
    [for r in module.teleport_integration_role : r.arn],
  )
  tags = merge(
    var.tags,
    {
      "teleport.dev/integration" = "true"
    },
  )
}

module "teleport_integration_role" {
  for_each = var.create ? local.clusters : {}

  create                  = var.create
  source                  = "../create-aws-iam-role"
  name                    = "${var.name_prefix}-${each.value.name}"
  description             = "${each.value.name} integration role ARN"
  trust_policy_principals = var.trust_policy_principals
  trust_policy_oidc_providers = [
    "arn:aws:iam::${local.account_id}:oidc-provider/${each.value.domain}",
  ]
  trust_policy_oidc_conditions = [
    {
      test     = "StringEquals"
      variable = "${each.value.domain}:aud"
      values   = ["discover.teleport"]
    },
  ]
  tags = each.value.tags
}

module "teleport_integration_db_svc_role" {
  for_each = var.create ? local.clusters : {}

  create                = var.create
  source                = "../create-aws-iam-role"
  name                  = "${var.name_prefix}-${each.value.name}-db-svc"
  description           = "${each.value.name} integration database service role ARN"
  trust_policy_services = ["ecs-tasks"]
  tags                  = each.value.tags
}

resource "aws_iam_policy" "db_access" {
  count = var.create ? 1 : 0

  description = "IAM policy for Teleport database access"
  name        = local.db_access_name
  path        = "/"
  policy      = file("${path.module}/db-access-policy.json")
  tags        = var.tags
}

resource "aws_iam_policy" "db_discovery" {
  count = var.create ? 1 : 0

  description = "IAM policy for Teleport database discovery"
  name        = local.db_discovery_name
  path        = "/"
  policy      = file("${path.module}/db-discovery-policy.json")
  tags        = var.tags
}

module "db_access" {
  source = "../create-aws-iam-role"

  create                  = var.create
  description             = "Teleport database access"
  name                    = local.db_access_name
  permission_policy_arns  = aws_iam_policy.db_access[*].arn
  trust_policy_principals = var.trust_policy_principals
  tags                    = var.tags
}

module "db_discovery" {
  source = "../create-aws-iam-role"

  create                  = var.create
  description             = "Teleport database discovery"
  name                    = local.db_discovery_name
  permission_policy_arns  = aws_iam_policy.db_discovery[*].arn
  trust_policy_principals = var.trust_policy_principals
  tags                    = var.tags
}
