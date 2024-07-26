variable "create" {
  description = "Determines whether to create the resources"
  type        = bool
  default     = true
  nullable    = false
}

variable "kube_sa" {
  description = "namespace:name of a kube service account to trust"
  type        = string
}

variable "role_name" {
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
