variable "create" {
  description = "Determines whether to create the vpc."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace for resource names."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block"
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The value \"${var.vpc_cidr}\" is not a valid IPv4 IP range"
  }
}

variable "az_names" {
  description = "The names of availability zones that the vpc should use"
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = length(var.az_names) == 0 || length(var.az_names) >= 2
    error_message = "At least two AZs must be used"
  }

  validation {
    condition     = length(var.az_names) == 0 || length(var.az_names) == length(distinct(var.az_names))
    error_message = "AZ names must be distinct and unique"
  }
}
