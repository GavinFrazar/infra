# required inputs.
variable "access_keypair_name" {
  description = "The Name of the AWS keypair to use for interacting with the self-hosted db ec2 instance."
  type        = string
}

variable "access_from_ip" {
  description = "The ip to allow network access from"
  type        = string
}

variable "subnet_id" {
  description = "The subnet to use when creating the self-hosted db ec2 instance(s)"
  type        = string
  default     = ""
}

# optional inputs.
variable "additional_tags" {
  description = "Additional tags to be applied to the resources"
  type        = map(string)
  default     = {}
}

variable "ami_id" {
  type        = string
  description = "the AMI to use to provision up Teleport instances"
  default     = "ami-014d05e6b24240371" // Ubuntu 22.04 in us-west-1
}

variable "ec2_instance_type" {
  description = "EC2 instance type to use for hosting databases."
  type        = string
  default     = "t3.2xlarge"
}

variable "ec2_instance_count" {
  description = "The number of self-hosted database ec2 instances to spin up."
  type        = number
  default     = 1
}
