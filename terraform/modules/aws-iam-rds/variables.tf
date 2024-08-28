variable "create" {
  description = "Determines whether to create the roles."
  type        = bool
  default     = true
  nullable    = false
}

variable "aws_account_id" {
  type     = string
  nullable = false
}

variable "aws_partition" {
  type     = string
  nullable = false
}

variable "namespace" {
  description = "Namespace for resource names."
  type        = string
  nullable    = false
}

variable "trust_policy_principals" {
  description = "The ARNs of AWS principals to put in the access/discovery role trust policies."
  type        = list(string)
  nullable    = false
}
