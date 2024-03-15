variable "enabled" {
  description = "Submodules that are enabled by default."
  type        = map(bool)
  default = {
    aws_rds_postgres        = false
    aws_redshift            = false
    aws_redshift_serverless = false
    aws_vpc                 = false
    azure_mysql             = false
    databases_host          = false
    e2e_tests               = false
    gcp_spanner             = true
    kube                    = false
  }
}
