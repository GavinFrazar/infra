module "this" {
  create_vpc = var.create
  source     = "terraform-aws-modules/vpc/aws"
  version    = "~> 5.0"

  azs                           = var.az_names
  cidr                          = var.vpc_cidr
  create_igw                    = true # create internet gateway and routes to it from public subnets.
  enable_dns_hostnames          = true
  enable_dns_support            = true
  enable_nat_gateway            = true
  manage_default_network_acl    = true # default. do not use, but prevent drift.
  manage_default_route_table    = true # default. do not use, but prevent drift.
  manage_default_security_group = true # default. do not use, but prevent drift.
  map_public_ip_on_launch       = true
  name                          = "${var.namespace}-vpc"
  private_dedicated_network_acl = true
  public_dedicated_network_acl  = true
  public_subnet_tags            = { "kubernetes.io/role/elb" = "1" }
  public_subnets                = [for i, _ in var.az_names : cidrsubnet(var.vpc_cidr, 4, i)]
  private_subnets               = [for i, _ in var.az_names : cidrsubnet(var.vpc_cidr, 4, i + length(var.az_names))]
  private_subnet_tags           = { "kubernetes.io/role/internal-elb" = "1" }
  single_nat_gateway            = true

  # set up database intra VPC subnets:
  database_subnets                       = [for i, _ in var.az_names : cidrsubnet(var.vpc_cidr, 4, i + 2 * length(var.az_names))]
  intra_subnets                          = [for i, _ in var.az_names : cidrsubnet(var.vpc_cidr, 4, i + 3 * length(var.az_names))]
  create_database_internet_gateway_route = false
  create_database_nat_gateway_route      = true
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true

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

  public_outbound_acl_rules = [
    {
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 100,
      "to_port" : 0
    }
  ]

  public_inbound_acl_rules = [
    {
      "cidr_block" : "0.0.0.0/0",
      "from_port" : 0,
      "protocol" : "-1",
      "rule_action" : "allow",
      "rule_number" : 100,
      "to_port" : 0
    },
  ]
}
