variable "allow_public_access_from_cidrs" {
  description = "IP CIDRs that have access to the databases"
  type        = set(string)
  default     = []
  nullable    = false
}

variable "create" {
  description = "Determines whether to create the resources"
  type        = bool
  default     = false
  nullable    = false
}

variable "name_prefix" {
  description = "The prefix to use for created resource names"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
