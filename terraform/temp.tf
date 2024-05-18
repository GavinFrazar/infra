resource "aws_iam_policy" "gha_db_admin" {
  count  = local.create_e2e_tests ? 1 : 0
  name   = "ci-database-e2e-tests-db-admin-access"
  path   = "/"
  policy = data.aws_iam_policy_document.gha_db_admin[0].json
}

data "aws_iam_policy_document" "gha_db_admin" {
  count = local.create_e2e_tests ? 1 : 0
  statement {
    sid    = "AllowRDSSecretsDiscovery"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
    ]
    resources = [
      module.e2e_tests[0].rds.mariadb_instance_arn,
      module.e2e_tests[0].rds.mysql_instance_arn,
      module.e2e_tests[0].rds.postgres_instance_arn,
    ]
  }

  # statement {
  #   sid    = "AllowRDSAuroraSecretsDiscovery"
  #   effect = "Allow"
  #   actions = [
  #     "rds:DescribeDBClusters",
  #   ]
  #   resources = [
  #     module.e2e_tests.rds_aurora_mysql.cluster_arn,
  #   ]
  # }

  statement {
    sid    = "AllowRedshiftSecretsDiscovery"
    effect = "Allow"
    actions = [
      "redshift:DescribeClusters",
    ]
    resources = [
      module.e2e_tests[0].redshift_cluster.cluster_arn,
    ]
  }

  statement {
    sid    = "AllowDBSecretsAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      module.e2e_tests[0].rds.mariadb_master_user_secret_arn,
      module.e2e_tests[0].rds.mysql_master_user_secret_arn,
      module.e2e_tests[0].rds.postgres_master_user_secret_arn,
      module.e2e_tests[0].redshift_cluster.master_user_secret_arn,
      # module.e2e_tests.rds_aurora_mysql.master_user_secret_arn,
    ]
  }
}

module "gha_db_admin" {
  count                   = local.create_e2e_tests ? 1 : 0
  create                  = true
  source                  = "./modules/create-aws-iam-role"
  name                    = "ci-database-e2e-tests-db-admin-access"
  description             = "GHA db admin role"
  permissions_policy_arn  = one(aws_iam_policy.gha_db_admin[*].arn)
  trust_policy_principals = local.trusted_role_arns
}
