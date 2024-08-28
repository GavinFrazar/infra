variable "allow_public_access_from_cidrs" {
  description = "IP CIDRs that have access to the databases"
  type        = set(string)
  default     = []
  nullable    = false
}

variable "create" {
  description = "Determines whether to create the database"
  type        = bool
  default     = true
  nullable    = false
}

variable "db_master_user" {
  description = "The database master username"
  type        = string
  default     = "master"
  nullable    = false
}

variable "name_prefix" {
  description = "The prefix to use for created resource names"
  type        = string
}

variable "postgres_port" {
  description = "The port to use for Postgres database connection endpoints"
  type        = number
  default     = 5432
  nullable    = false
}

variable "subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group"
  type        = string
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
