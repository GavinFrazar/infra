variable "enabled" {
  description = "Submodules that are enabled by default."
  type        = map(map(bool))

  default = {
    aws = {
      ci_e2e_test         = false
      databases_host      = false
      ecr                 = true
      eks                 = true
      eks_addons          = true
      rds_postgres        = true
      redshift            = false
      redshift_serverless = false
      vpc                 = true
    }

    gcp = {
      spanner = false
      kube    = false
    }

    azure = {
      mysql = false
    }
  }
}
