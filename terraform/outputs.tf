output "aws_ci_e2e_test" {
  value = module.aws_ci_e2e_test
}

output "aws_databases_host_ip" {
  value = module.aws_databases_host.public_ip
}

output "aws_db_iam_roles" {
  description = "AWS IAM Roles that Teleport users can use for databases."
  value = compact([
    module.aws_iam_redshift_serverless_user.role_arn,
  ])
}

output "aws_teleport_iam_roles" {
  description = "AWS IAM roles that Teleport should assume."
  value = compact([
    module.aws_iam_rds.access_role_arn,
    module.aws_iam_rds.discovery_role_arn,

    module.aws_iam_rds_proxy.access_role_arn,
    module.aws_iam_rds_proxy.discovery_role_arn,

    module.aws_iam_redshift.access_role_arn,
    module.aws_iam_redshift.discovery_role_arn,

    module.aws_iam_redshift_serverless.access_role_arn,
    module.aws_iam_redshift_serverless.discovery_role_arn,

    module.aws_iam_combined.access_role_arn,
    module.aws_iam_combined.discovery_role_arn,
  ])
}

output "client_info" {
  value = {
    "ip" = local.my_ip,
    "aws" = {
      "partition" = data.aws_partition.this.partition,
      "identity"  = data.aws_caller_identity.this.arn,
    },
    "gcp" = {
      "project"  = data.google_project.this.project_id,
      "identity" = data.google_client_openid_userinfo.this.id,
    },
  }
}

output "db_endpoints" {
  description = "Endpoints for created databases."
  value = compact([
    module.gcp_spanner.googlesql_db,
    module.gcp_spanner.postgresql_db,
    module.aws_redshift.endpoint,
  ])
}

output "gcp_teleport_iam_roles" {
  description = "GCP IAM roles that Teleport should assume."
  value = compact([
    module.gcp_iam_spanner.access_service_account,
  ])
}

output "gcp_db_iam_roles" {
  description = "GCP IAM Roles that Teleport users can use for databases."
  value = compact([
    module.gcp_iam_spanner.admin_user_service_account,
    module.gcp_iam_spanner.user_service_account,
  ])
}

output "iam_tester_role" {
  value = module.aws_iam_tester.role_arn
}

output "temporal" {
  value = {
    "tbot_role_arn" = module.temporal.tbot_role_arn
  }
}
