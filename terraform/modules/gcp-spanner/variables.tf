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
