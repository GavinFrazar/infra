variable "oidc_provider_arn" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name (id)"
}

variable "create" {
  description = "Determines whether to create the resources"
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "The prefix to use for created resource names"
  type        = string
}

variable "oidc_domain" {
  type        = string
  description = "EKS cluster OIDC issuer domain"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
