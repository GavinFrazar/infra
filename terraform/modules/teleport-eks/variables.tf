variable "ecr_repo" {
  description = "ECR repo name"
  type        = string
  nullable    = false
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "create" {
  description = "Determines whether to create the resources"
  type        = bool
  default     = true
  nullable    = false
}

variable "name_prefix" {
  description = "The prefix to use for created resource names"
  type        = string
  nullable    = false
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
