variable "enabled" {
  description = "Submodules that are enabled by default."
  type        = map(bool)

  default = {
    aws_ci_e2e_test         = false
    aws_databases_host      = false
    aws_ecr                 = true
    aws_eks                 = true
    aws_rds_postgres        = true
    aws_redshift            = false
    aws_redshift_serverless = false
    aws_vpc                 = false

    gcp_spanner = false

    azure_mysql = false

    kube        = false
  }
}
