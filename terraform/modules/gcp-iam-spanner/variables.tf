variable "create" {
  description = "Determines whether to create the service accounts."
  type        = bool
  default     = true
  nullable    = false
}

variable "namespace" {
  description = "Namespace for resource names."
  type        = string
  nullable    = false
}

variable "spanner_instance_names" {
  description = "GCP spanner instance names (should not include project/)."
  type        = list(string)
  nullable    = false
}

variable "trusted_impersonators" {
  description = "List of GCP IAM $type:$principal that can impersonate the service accounts."
  type        = list(string)
  nullable    = false
}
