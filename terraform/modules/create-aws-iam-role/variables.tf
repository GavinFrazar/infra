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

variable "permission_policy_arns" {
  type     = list(string)
  default  = []
  nullable = false
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "trust_policy_principals" {
  description = "The ARNs of AWS principals to put in the role trust policy."
  type        = list(string)
  default     = []
  nullable    = true
}

variable "trust_policy_services" {
  description = "The ARNs of AWS services to put in the role trust policy."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "trust_policy_oidc_providers" {
  description = "The ARNs of AWS IAM OIDC providers to put in the role trust policy."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "trust_policy_oidc_conditions" {
  description = "The OIDC provider conditions."
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default  = []
  nullable = false
}

variable "trust_session_tags" {
  description = "Whether or not trusted principals can pass session tags when assuming this role"
  type        = bool
  default     = false
}
