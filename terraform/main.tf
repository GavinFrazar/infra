resource "aws_key_pair" "ssh" {
  count      = local.create_aws_key_pair ? 1 : 0
  key_name   = "${local.namespace}-ssh"
  public_key = local.my_ssh_public_key
}

# RDS
# module "aws_rds_postgres" {
#   count     = local.create_aws_rds_postgres ? 1 : 0
#   source    = "./modules/aws-rds-postgres"
#   namespace = local.namespace
# }

module "aws_iam_rds" {
  create                  = local.create_aws_iam_rds
  source                  = "./modules/aws-iam-rds"
  aws_account_id          = data.aws_caller_identity.this.account_id
  aws_partition           = data.aws_partition.this.partition
  namespace               = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

# RDS Proxy
module "aws_iam_rds_proxy" {
  create                  = local.create_aws_iam_rds_proxy
  source                  = "./modules/aws-iam-rds-proxy"
  namespace               = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

# Redshift
module "aws_redshift" {
  create    = local.create_aws_redshift
  source    = "./modules/aws-redshift"
  namespace = local.namespace
}

module "aws_iam_redshift" {
  create                  = local.create_aws_iam_redshift
  source                  = "./modules/aws-iam-redshift"
  aws_account_id          = data.aws_caller_identity.this.account_id
  aws_partition           = data.aws_partition.this.partition
  namespace               = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

# Redshift (Serverless)
module "aws_redshift_serverless" {
  create    = local.create_aws_redshift_serverless
  source    = "./modules/aws-redshift-serverless"
  namespace = local.namespace
  # stubs, i'm gonna remove this module probably.
  security_group_ids = [null]
  subnet_ids         = [null]
}

module "aws_iam_redshift_serverless" {
  create                  = local.create_aws_iam_redshift_serverless
  source                  = "./modules/aws-iam-redshift-serverless"
  namespace               = local.namespace
  trust_policy_principals = local.trusted_role_arns
}

module "aws_iam_redshift_serverless_user" {
  create                  = local.create_aws_iam_redshift_serverless_user
  source                  = "./modules/aws-iam-redshift-serverless-user"
  name                    = "${local.namespace}-redshift-serverless-user"
  trust_policy_principals = [module.aws_iam_redshift_serverless.access_role_arn]
  workgroup_arns          = [module.aws_redshift_serverless.workgroup_arn]
}

module "azure_mysql" {
  create    = local.create_azure_mysql
  source    = "./modules/azure-mysql"
  namespace = local.namespace
}

module "vpc" {
  create = local.create_vpc
  source = "./modules/vpc"

  az_names  = data.aws_availability_zones.this.names
  namespace = local.namespace
  vpc_cidr  = "192.168.0.0/20"
}

module "databases_host" {
  create    = local.create_databases_host
  source    = "./modules/databases-host"
  namespace = local.namespace

  access_key_pair_name = one(aws_key_pair.ssh[*].key_name)
  access_from_ip       = local.my_ip
  subnet_id            = try(module.vpc.vpc.public_subnets[0], "")
  vpc_id               = module.vpc.vpc.vpc_id
}

module "kube" {
  create    = local.create_kube
  source    = "./modules/kube"
  namespace = local.namespace

  access_from_ip = local.my_ip
}

# gcp
module "gcp_spanner" {
  create    = local.create_gcp_spanner
  source    = "./modules/gcp-spanner"
  namespace = local.namespace
}

module "gcp_iam_spanner" {
  create                 = local.create_gcp_spanner_iam
  source                 = "./modules/gcp-iam-spanner"
  namespace              = local.namespace
  spanner_instance_names = [module.gcp_spanner.instance_name]
  trusted_impersonators  = local.trusted_impersonators
}

module "e2e_tests" {
  count  = local.create_e2e_tests ? 1 : 0
  source = "/Users/gavin/code/cloud-terraform//aws/modules/databases-ci"

  # create                           = local.create_e2e_tests
  public_access_ip_ranges          = local.public_access_ip_ranges
  vpc_cidr                         = "10.0.0.0/20"
  name_prefix                      = "ci-database-e2e-tests"
  role_trust_policy_principal_arns = concat(local.trusted_role_arns, [module.gha_db_admin[0].role_arn])
}
