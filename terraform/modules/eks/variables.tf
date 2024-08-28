variable "cluster_admin_arns" {
  description = "List of AWS IAM role ARNs to create a system:masters access entry for"
  type        = list(string)
  nullable    = false
}

variable "cluster_version" {
  description = "kube cluster version"
  type        = string
  nullable    = false
}

variable "create" {
  description = "Determines whether to create the resources"
  type        = bool
  default     = true
  nullable    = false
}

variable "create_addons" {
  description = "Determines whether to create the addon resources (requires kubeconfig)"
  type        = bool
  default     = true
  nullable    = false
}

variable "name_prefix" {
  description = "The prefix to use for created resource names"
  type        = string
  nullable    = false
}

variable "public_access_ip_ranges" {
  description = "IP ranges that have access to the resources"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "subnet_ids" {
  type     = list(string)
  default  = []
  nullable = false
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
