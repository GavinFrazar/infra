locals {
  # --- naming ---
  name              = "gavin"
  namespace         = "${local.name}-tf"
  teleport_db_admin = "teleport-admin"

  # --- tags ---
  default_tags = {
    env    = "dev"
    method = "terraform"
    origin = local.name
  }
  aws_default_tags = merge(local.default_tags, {
    "teleport.dev/creator" = "gavin.frazar@goteleport.com"
  })
  gcp_default_tags = merge(local.default_tags, {
  })
  db_admin_tag = {
    "teleport.dev/db-admin" = local.teleport_db_admin
  }

  # --- me ---
  my_ip             = chomp(data.http.my_ip.response_body)
  my_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJAG523NTKBt+Wd5vp3foDsxzLcT7xnYZVA3WGLIBykO gavin@mac.attlocal.net"
  federated_role_arns = {
    teleport_dev_2 = "arn:aws:iam::651149123960:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_AWSAdministratorAccess_5b57a14d5c6ff9fb"
  }

  # --- access controls ---
  # TODO: move this into the EKS module outputs. Keep both url and domain.
  eks_oidc_domain = trimprefix(module.eks.oidc_issuer_url, "https://")
  # TODO: rename this to allow_public_access_from_cidrs
  public_access_ip_ranges = sensitive([
    "${local.my_ip}/32",
  ])
  # These GCP IAM principals can impersonate any IAM principles created.
  trusted_impersonators = [
    "user:${data.google_client_openid_userinfo.this.email}",
  ]
  # These AWS identites can assume any IAM roles created.
  trusted_role_arns = [
    data.aws_caller_identity.this.arn
  ]

  # --- resource creation controls ---
  # To change what is enabled by default, you should edit var.enabled.
  # The local vars should not be edited because it messes up scripts
  # that depend on defaults.
  ## AWS
  create_aws_ci_e2e_test         = lookup(var.enabled, "aws_ci_e2e_test", false)
  create_aws_databases_host      = lookup(var.enabled, "aws_databases_host", false)
  create_aws_ecr                 = lookup(var.enabled, "aws_ecr", false) || local.create_aws_eks
  create_aws_eks                 = lookup(var.enabled, "aws_eks", false)
  create_aws_key_pair            = local.create_aws_databases_host
  create_aws_rds_postgres        = lookup(var.enabled, "aws_rds_postgres", false)
  create_aws_redshift            = lookup(var.enabled, "aws_redshift", false)
  create_aws_redshift_serverless = lookup(var.enabled, "aws_redshift_serverless", false)
  create_aws_vpc                 = lookup(var.enabled, "aws_vpc") || local.create_aws_databases_host || local.create_aws_eks

  ## AWS IAM
  create_aws_iam_combined                 = true  # TODO: make it a var
  create_aws_iam_rds                      = true  # TODO: make it a var
  create_aws_iam_rds_proxy                = false # TODO: make it a var
  create_aws_iam_redshift                 = local.create_aws_redshift || false
  create_aws_iam_redshift_serverless      = local.create_aws_redshift_serverless || false
  create_aws_iam_redshift_serverless_user = local.create_aws_redshift_serverless || false
  create_aws_iam_tester                   = true # TODO: make it a var

  ## GCP
  create_gcp_spanner = lookup(var.enabled, "gcp_spanner", false)
  create_kube        = lookup(var.enabled, "kube", false)

  ## GCP IAM
  create_gcp_spanner_iam = local.create_gcp_spanner || false

  ## Azure
  create_azure_mysql = lookup(var.enabled, "azure_mysql", false)
}
