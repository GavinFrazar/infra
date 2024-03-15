variable "create" {
  description = "Determines whether to create the user."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of the role."
  type        = string
  nullable    = false
}

variable "trust_policy_principals" {
  description = "The ARNs of AWS principals to put in the IAM db role trust policy."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "workgroup_arns" {
  description = "List of redshift serverless workgroup ARNs the role can auth to."
  type        = list(string)
  default     = []
  nullable    = false
}
