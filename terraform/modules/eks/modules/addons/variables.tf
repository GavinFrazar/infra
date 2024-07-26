variable "oidc_provider_arn" {
  type     = string
  nullable = false
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name (id)"
}

variable "create" {
  description = "Determines whether to create the resources"
  type        = bool
  default     = true
  nullable    = false
}

variable "name_prefix" {
  description = "The prefix to use for created resource names"
  type        = string
  nullable    = false
}

variable "oidc_domain" {
  type        = string
  description = "EKS cluster OIDC issuer domain"
  nullable    = false
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
