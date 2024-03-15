module "vpc" {
  create_vpc = var.create
  source     = "terraform-aws-modules/vpc/aws"
  version    = "~> 5.0"

  name = "${var.namespace}-vpc"
  cidr = var.vpc_cidr

  # TODO(gavin): add elasticache and redshift for e2e tests.
  azs = var.az_names
  public_subnets =  [
    for i, _ in var.az_names : cidrsubnet(var.vpc_cidr, 4, i)
  ]

  enable_dns_hostnames = true
  enable_dns_support   = true

  # These differs from the normal defaults as they do not allow IPv6 traffic.
  # Resources inside the cluster do not support IPv6, so there is no reason to
  # allow it here.
  default_network_acl_egress = [
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 100,
      "to_port" : 0
    }
  ]

  default_network_acl_ingress = [
    {
      "action" : "allow",
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_no" : 100,
      "to_port" : 0
    },
  ]
}
