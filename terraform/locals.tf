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
  azure_default_tags = merge(local.default_tags, {
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

  # --- my Teleport clusters ---
  cluster_domains = [
    "alpha.devteleport.com",
    "beta.devteleport.com",
    "gavin-leaf.cloud.gravitational.io",
    "gavin-test.trunk.cloud.teleportinfra.dev",
    "mars.internal"
  ]
  clusters = [
    for d in local.cluster_domains :
    {
      name   = replace(d, ".", "-")
      domain = d
    }
  ]

  # --- access controls ---
  allow_public_db_access  = true
  allow_public_eks_access = false // TODO: this isn't doing anything yet.
  allow_public_access_from_cidrs = toset([
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
  create_aws_ci_e2e_test         = var.create_aws_ci_e2e_test
  create_aws_databases_host      = var.create_aws_databases_host
  create_aws_ecr                 = var.create_aws_ecr || local.create_aws_eks
  create_aws_eks                 = var.create_aws_eks
  create_aws_eks_addons          = var.create_aws_eks_addons
  create_aws_key_pair            = var.create_aws_key_pair || local.create_aws_databases_host
  create_aws_rds_postgres        = var.create_aws_rds_postgres
  create_aws_redshift            = var.create_aws_redshift
  create_aws_redshift_serverless = var.create_aws_redshift_serverless
  create_aws_vpc                 = var.create_aws_vpc || local.create_aws_databases_host || local.create_aws_eks

  ## AWS IAM
  create_aws_iam_roles                    = var.create_aws_iam_roles
  create_aws_iam_redshift_serverless_user = local.create_aws_redshift_serverless

  ## GCP
  create_gcp_spanner = var.create_gcp_spanner
  create_gcp_kube    = var.create_gcp_kube

  ## GCP IAM
  create_gcp_spanner_iam = var.create_gcp_spanner_iam || var.create_gcp_spanner

  ## Azure
  create_azure_mysql = var.create_azure_mysql
  create_azure_vm    = var.create_azure_vm

  ## Misc
  create_temporal     = false
  create_teleport_eks = true

  # --- misc ---
  gcp_project = {
    id     = data.google_project.this.project_id,
    name   = data.google_project.this.name,
    number = data.google_project.this.number,
  }
}
