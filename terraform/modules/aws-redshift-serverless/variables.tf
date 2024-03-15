variable "create" {
  description = "Determines whether to create the database."
  type        = bool
  default     = true
  nullable    = false
}

variable "namespace" {
  description = "Namespace for resource names."
  type        = string
  nullable    = false
}

variable "allow_public_access" {
  description = "True if databases should be publicly accessible, false otherwise"
  type        = bool
  nullable    = false
  default     = false
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs to associate"
  type        = list(string)
  nullable    = false
}

variable "security_group_ids" {
  description = "List of security groups to associate"
  type        = list(string)
  nullable    = false
}
