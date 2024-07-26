data "aws_iam_policy_document" "gha_db_admin" {
  count = var.create ? 1 : 0

  statement {
    sid    = "AllowRDSSecretsDiscovery"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
    ]
    resources = [
      module.databases_ci[0].rds.mariadb_instance_arn,
      module.databases_ci[0].rds.mysql_instance_arn,
      module.databases_ci[0].rds.postgres_instance_arn,
    ]
  }

  # statement {
  #   sid    = "AllowRDSAuroraSecretsDiscovery"
  #   effect = "Allow"
  #   actions = [
  #     "rds:DescribeDBClusters",
  #   ]
  #   resources = [
  #     module.databases_ci.rds_aurora_mysql.cluster_arn,
  #   ]
  # }

  statement {
    sid    = "AllowRedshiftSecretsDiscovery"
    effect = "Allow"
    actions = [
      "redshift:DescribeClusters",
    ]
    resources = [
      module.databases_ci[0].redshift_cluster.cluster_arn,
    ]
  }

  statement {
    sid    = "AllowDBSecretsAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      module.databases_ci[0].rds.mariadb_master_user_secret_arn,
      module.databases_ci[0].rds.mysql_master_user_secret_arn,
      module.databases_ci[0].rds.postgres_master_user_secret_arn,
      module.databases_ci[0].redshift_cluster.master_user_secret_arn,
      # module.databases_ci.rds_aurora_mysql.master_user_secret_arn,
    ]
  }
}
