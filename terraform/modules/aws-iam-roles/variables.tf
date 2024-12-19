variable "clusters" {
  description = "Teleport clusters"
  type = list(object({
    name   = string
    domain = string
  }))
}

variable "create" {
  description = "Determines whether to create the roles."
  type        = bool
  default     = true
  nullable    = false
}

variable "name_prefix" {
  description = "Name prefix for resource names."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "trust_policy_principals" {
  description = "The ARNs of AWS principals to put in all the role trust policies."
  type        = list(string)
  nullable    = false
}
