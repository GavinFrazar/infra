variable "create" {
  description = "Determines whether to create the kube cluster."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace for resource names."
  type        = string
}

variable "access_from_ip" {
  description = "The ip to allow network access from"
  type        = string
}
