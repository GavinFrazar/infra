variable "create" {
  description = "Determines whether to create the role."
  type        = bool
  default     = true
}

variable "description" {
  type        = string
  description = "Description of the new role."
}

variable "name" {
  type        = string
  description = "Name of the new role."
}

variable "permissions_boundary_arn" {
  type    = string
  default = null
}

variable "permissions_policy_arn" {
  type = string
}

variable "trust_policy_principals" {
  description = "The ARNs of AWS principals to put in the access/discovery role trust policies."
  type        = list(string)
  default     = []
  nullable    = false
}
