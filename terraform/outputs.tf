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
  ])
}

output "gcp_teleport_iam_roles" {
  description = "GCP IAM roles that Teleport should assume."
  value = compact([
    module.gcp_iam_spanner.access_service_account,
  ])
}

output "aws_db_iam_roles" {
  description = "AWS IAM Roles that Teleport users can use for databases."
  value = compact([
    module.aws_iam_redshift_serverless_user.role_arn,
  ])
}

output "gcp_db_iam_roles" {
  description = "GCP IAM Roles that Teleport users can use for databases."
  value = compact([
    module.gcp_iam_spanner.admin_user_service_account,
    module.gcp_iam_spanner.user_service_account,
  ])
}

output "db_endpoints" {
  description = "Endpoints for created databases."
  value = compact([
    module.gcp_spanner.googlesql_db,
    module.gcp_spanner.postgresql_db,
    module.aws_redshift.endpoint,
  ])
}

output "databases_host_ip" {
  value = module.databases_host.public_ip
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

output "zzz_testing" {
  value = try(merge(module.e2e_tests[0], {
    "fake-ci-role" = module.gha_db_admin.role_arn,
  }), {})
}
