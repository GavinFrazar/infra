# required inputs.
variable "create" {
  description = "Determines whether to create the databases host."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace for resource names."
  type        = string
  nullable    = false
}

variable "access_key_pair_name" {
  description = "The Name of the AWS keypair to use for interacting with the self-hosted db ec2 instance."
  type        = string
  default     = ""
  nullable    = false
}

variable "access_from_ip" {
  description = "The ip to allow network access from"
  type        = string
  nullable    = false
}

# optional inputs.
variable "ami_id" {
  type        = string
  description = "the AMI to use to provision up Teleport instances"
  # default     = "ami-014d05e6b24240371" // Ubuntu 22.04 in us-west-1
  default  = "ami-08116b9957a259459" // Ubuntu 22.04 in us-west-2
  nullable = false
}

variable "ec2_instance_type" {
  description = "EC2 instance type to use for hosting databases."
  type        = string
  default     = "t3.2xlarge"
  nullable    = false
}

variable "subnet_id" {
  description = "The subnet to use when creating the self-hosted db ec2 instance(s)"
  type        = string
  default     = ""
  nullable    = false
}

variable "vpc_id" {
  description = "The vpc to use when creating the self-hosted db ec2 instance(s)"
  type        = string
  default     = ""
  nullable    = false
}
