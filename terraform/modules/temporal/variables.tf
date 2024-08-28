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

variable "teleport_cluster_name" {
  type = string
}

variable "teleport_cluster_proxy_addr" {
  type = string
}

variable "oidc_domain" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
