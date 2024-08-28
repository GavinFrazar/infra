# AWS
resource "aws_key_pair" "ssh" {
  count = local.create_aws_key_pair ? 1 : 0

  key_name   = "${local.namespace}-ssh"
  public_key = local.my_ssh_public_key
}

module "aws_iam_tester" {
  source = "./modules/aws-iam-tester"

  create                  = local.create_aws_iam_tester
  name_prefix             = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

## RDS
module "aws_rds_postgres" {
  source = "./modules/aws-rds-postgres"

  allow_public_access_from_cidrs = local.allow_public_access_from_cidrs
  create                         = local.create_aws_rds_postgres
  name_prefix                    = local.namespace
  subnet_group_name              = module.vpc.database_subnet_group_name
  vpc_id                         = module.vpc.id
  tags                           = merge(local.aws_default_tags, local.db_admin_tag)
}

module "aws_iam_combined" {
  source = "./modules/aws-iam-combined"

  create                  = local.create_aws_iam_combined
  name_prefix             = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

module "aws_iam_rds" {
  source = "./modules/aws-iam-rds"

  create                  = local.create_aws_iam_rds
  aws_account_id          = data.aws_caller_identity.this.account_id
  aws_partition           = data.aws_partition.this.partition
  namespace               = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

## RDS Proxy
module "aws_iam_rds_proxy" {
  source = "./modules/aws-iam-rds-proxy"

  create                  = local.create_aws_iam_rds_proxy
  namespace               = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

## Redshift
module "aws_redshift" {
  source = "./modules/aws-redshift"

  create    = local.create_aws_redshift
  namespace = local.namespace
}

module "aws_iam_redshift" {
  source = "./modules/aws-iam-redshift"

  create                  = local.create_aws_iam_redshift
  aws_account_id          = data.aws_caller_identity.this.account_id
  aws_partition           = data.aws_partition.this.partition
  namespace               = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

## Redshift (Serverless)
module "aws_redshift_serverless" {
  source = "./modules/aws-redshift-serverless"

  create    = local.create_aws_redshift_serverless
  namespace = local.namespace
  # stubs, i'm gonna remove this module probably.
  security_group_ids = [null]
  subnet_ids         = [null]
}

module "aws_iam_redshift_serverless" {
  source = "./modules/aws-iam-redshift-serverless"

  create                  = local.create_aws_iam_redshift_serverless
  namespace               = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

module "aws_iam_redshift_serverless_user" {
  source = "./modules/aws-iam-redshift-serverless-user"

  create                  = local.create_aws_iam_redshift_serverless_user
  name                    = "${local.namespace}-redshift-serverless-user"
  trust_policy_principals = [module.aws_iam_redshift_serverless.access_role_arn]
  workgroup_arns          = [module.aws_redshift_serverless.workgroup_arn]
}

## Misc
module "aws_ci_e2e_test" {
  source = "./modules/aws-ci-e2e-test"

  create                  = local.create_aws_ci_e2e_test
  public_access_ip_ranges = local.allow_public_access_from_cidrs
  # Trust these roles to assume the pseudo gha role, i.e. you still have to
  # chain roles. This way when I test changes I can't forget to update the
  # gha role permissions.
  gha_db_admin_trusted_role_arns = local.trusted_role_arns
}

module "vpc" {
  source = "./modules/vpc"

  az_names  = data.aws_availability_zones.this.names
  create    = local.create_aws_vpc
  namespace = local.namespace
  vpc_cidr  = "192.168.0.0/16"
}

module "eks" {
  source = "./modules/eks"

  create        = local.create_aws_eks
  create_addons = local.create_aws_eks_addons

  # give myself cluster admin.
  cluster_admin_arns      = [local.federated_role_arns.teleport_dev_2]
  cluster_version         = "1.29"
  name_prefix             = local.namespace
  public_access_ip_ranges = local.allow_public_access_from_cidrs
  subnet_ids              = module.vpc.public_subnets
  vpc_id                  = module.vpc.id
  # pass tags because the default provider tags aren't propagated to all
  # resource types, e.g. node group instances.
  tags = local.aws_default_tags
}

module "aws_ecr" {
  source = "./modules/aws-ecr"

  create      = local.create_aws_ecr
  name_prefix = local.namespace
}

module "teleport_eks" {
  source = "./modules/teleport-eks"

  create           = local.create_teleport_eks
  ecr_repo         = module.aws_ecr.repository_url
  eks_cluster_name = module.eks.id
  name_prefix      = local.namespace
  tags             = local.aws_default_tags
}

module "temporal" {
  source = "./modules/temporal"

  create            = local.create_temporal
  name_prefix       = local.namespace
  oidc_domain       = module.eks.oidc_domain
  oidc_provider_arn = module.eks.aws_iam_oidc_provider_arn
  # teleport_cluster_name       = "alpha.devteleport.com"
  # teleport_cluster_proxy_addr = "alpha.devteleport.com:443"
  teleport_cluster_name       = "gavin-leaf.cloud.gravitational.io"
  teleport_cluster_proxy_addr = "gavin-leaf.cloud.gravitational.io:443"
}

## ec2 instance and networking for running self-hosted databases in docker,
## but I plan to eliminate this in favor of deploying self-hosted databases
## entirely in kubernetes.
module "aws_databases_host" {
  create    = local.create_aws_databases_host
  source    = "./modules/databases-host"
  namespace = local.namespace

  access_key_pair_name = one(aws_key_pair.ssh[*].key_name)
  access_from_ip       = local.my_ip
  subnet_id            = try(module.vpc.public_subnets[0], "")
  vpc_id               = module.vpc.id
}

# GCP
module "gcp_spanner" {
  source = "./modules/gcp-spanner"

  create    = local.create_gcp_spanner
  namespace = local.namespace
}

module "gcp_iam_spanner" {
  source = "./modules/gcp-iam-spanner"

  create                 = local.create_gcp_spanner_iam
  namespace              = local.namespace
  spanner_instance_names = [module.gcp_spanner.instance_name]
  trusted_impersonators  = local.trusted_impersonators
}

module "kube" {
  source = "./modules/kube"

  create    = local.create_gcp_kube
  namespace = local.namespace

  access_from_ip = local.my_ip
}

# Azure
module "azure_mysql" {
  source = "./modules/azure-mysql"

  create    = local.create_azure_mysql
  namespace = local.namespace
}
