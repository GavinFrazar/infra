variable "allow_public_access" {
  type    = bool
  default = false
}

variable "allow_public_access_from_cidrs" {
  description = "IP CIDRs that have access to the databases"
  type        = set(string)
  default     = []
  nullable    = false
}

variable "create" {
  description = "Determines whether to create the database."
  type        = bool
  default     = true
  nullable    = false
}

variable "name_prefix" {
  description = "Namespace for resource names."
  type        = string
  nullable    = false
}

variable "port" {
  description = "The port to use for the database connection endpoint"
  type        = number
  default     = 5439
  nullable    = false
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs to associate"
  type        = list(string)
  nullable    = false
}
