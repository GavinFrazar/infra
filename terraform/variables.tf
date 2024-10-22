variable "create_aws_ci_e2e_test" {
  type    = bool
  default = false
}

variable "create_aws_databases_host" {
  type    = bool
  default = false
}

variable "create_aws_ecr" {
  type    = bool
  default = false
}

variable "create_aws_eks" {
  type    = bool
  default = false
}

variable "create_aws_eks_addons" {
  type    = bool
  default = false
}

variable "create_aws_key_pair" {
  type    = bool
  default = false
}

variable "create_aws_rds_postgres" {
  type    = bool
  default = false
}

variable "create_aws_redshift" {
  type    = bool
  default = false
}

variable "create_aws_redshift_serverless" {
  type    = bool
  default = false
}

variable "create_aws_vpc" {
  type    = bool
  default = false
}

variable "create_gcp_spanner" {
  type    = bool
  default = false
}

variable "create_gcp_kube" {
  type    = bool
  default = false
}

variable "create_azure_mysql" {
  type    = bool
  default = false
}
