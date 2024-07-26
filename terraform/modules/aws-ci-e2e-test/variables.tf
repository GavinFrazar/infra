variable "create" {
  description = "Determines whether to create the vpc."
  type        = bool
  default     = true
}

variable "gha_db_admin_trusted_role_arns" {
  description = "List of IAM identity ARNs for the GHA role to trust."
  type        = list(string)
  nullable    = false
}

variable "public_access_ip_ranges" {
  description = "IP ranges that have access to the resources"
  type        = list(string)
  default     = []
  nullable    = false
}
