variable "create" {
  description = "Determines whether to create the role."
  type        = bool
  default     = true
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
