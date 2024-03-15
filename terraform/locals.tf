locals {
  name      = "gavin"
  namespace = "${local.name}-tf"

  my_ip             = chomp(data.http.my_ip.response_body)
  my_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAG523NTKBt+Wd5vp3foDsxzLcT7xnYZVA3WGLIBykO gavin@mac.attlocal.net"

  default_tags = {
    env    = "dev"
    method = "terraform"
    origin = local.name
  }

  # To change what is enabled by default, you should edit var.enabled.
  # This local var should not be edited.
  create_aws_rds_postgres        = lookup(var.enabled, "aws_rds_postgres", false)
  create_aws_redshift            = lookup(var.enabled, "aws_redshift", false)
  create_aws_redshift_serverless = lookup(var.enabled, "aws_redshift_serverless", false)
  create_azure_mysql             = lookup(var.enabled, "azure_mysql", false)
  create_databases_host          = lookup(var.enabled, "databases_host", false)
  create_e2e_tests               = lookup(var.enabled, "e2e_tests", false)
  create_gcp_spanner             = lookup(var.enabled, "gcp_spanner", false)
  create_kube                    = lookup(var.enabled, "kube", false)
  create_aws_key_pair            = false || local.create_databases_host
  create_vpc                     = false || local.create_databases_host

  # Create IAM roles?
  ## AWS
  create_aws_iam_rds                      = false
  create_aws_iam_rds_proxy                = false
  create_aws_iam_redshift                 = local.create_aws_redshift || false
  create_aws_iam_redshift_serverless      = local.create_aws_redshift_serverless || false
  create_aws_iam_redshift_serverless_user = local.create_aws_redshift_serverless || false
  ## GCP
  create_gcp_spanner_iam = local.create_gcp_spanner || false

  # These arns can assume any IAM roles created.
  trusted_role_arns = [
    data.aws_caller_identity.this.arn
  ]

  # These GCP IAM principals can impersonate any IAM principles created.
  trusted_impersonators = [
    "user:${data.google_client_openid_userinfo.this.email}",
  ]

  # TODO: vpc, security groups, subnets, etc. isolated. stop using default vpc/sg/subnet.

  # CI testing stuff
  teleport_db_user = "teleport-ci-e2e-test"
  public_access_ip_ranges = sensitive([
    "${local.my_ip}/32",
  ])
}
