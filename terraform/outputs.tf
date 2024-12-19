output "aws_ci_e2e_test" {
  value = module.aws_ci_e2e_test
}

output "aws_databases_host_ip" {
  value = module.aws_databases_host.public_ip
}

output "aws_db_iam_roles" {
  description = "AWS IAM Roles that Teleport users can use for databases."
  value = sort(compact([
    module.aws_iam_redshift_serverless_user.arn,
  ]))
}

output "aws_teleport_service_iam_roles" {
  description = "AWS IAM roles that Teleport services should assume."
  value = sort(compact([
    module.aws_iam_roles.db_access_role.arn,
    module.aws_iam_roles.db_discovery_role.arn,
  ]))
}

output "aws_teleport_integration_iam_roles" {
  description = "AWS IAM roles that Teleport integrations should assume."
  value       = sort([for r in module.aws_iam_roles.integration_roles : r.arn])
}

output "aws_teleport_integration_db_svc_iam_roles" {
  description = "AWS IAM roles that Teleport database services, deployed by ECS integration, should assume."
  value       = sort([for r in module.aws_iam_roles.integration_db_svc_roles : r.arn])
}

output "client_info" {
  value = {
    ip = local.my_ip,
    aws = {
      partition = data.aws_partition.this.partition,
      identity  = data.aws_caller_identity.this.arn,
    },
    gcp = {
      project  = local.gcp_project
      identity = data.google_client_openid_userinfo.this.id,
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

output "ecr_repo_url" {
  value = module.aws_ecr.repository_url
}

output "gcp_teleport_iam_roles" {
  description = "GCP IAM roles that Teleport should assume."
  value = compact([
    module.gcp_iam_spanner.spanner_access_service_account,
    module.gcp_iam_spanner.gcloud_controller_service_account,
  ])
}

output "gcp_db_iam_roles" {
  description = "GCP IAM Roles that Teleport users can use for databases."
  value = compact([
    module.gcp_iam_spanner.spanner_admin_user_service_account,
    module.gcp_iam_spanner.spanner_user_service_account,
  ])
}

output "temporal" {
  value = {
    tbot_role_arn = module.temporal.tbot_role_arn
  }
}

output "azure_vm" {
  value = {
    public_ip = module.azure_vm.public_ip
  }
}
