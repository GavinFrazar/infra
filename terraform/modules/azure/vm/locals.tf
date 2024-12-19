locals {
  name_prefix = var.name_prefix

  vpc_cidr        = "10.0.0.0/16"
  prefix_ext      = 8
  subnet_cidr_gap = 10
  subnet          = cidrsubnet(local.vpc_cidr, local.prefix_ext, local.subnet_cidr_gap)

  allow_public_access_from_cidrs = compact(sort(tolist(var.allow_public_access_from_cidrs)))

  root_management_group_id = "/providers/Microsoft.Management/managementGroups/ff882432-09b0-437b-bd22-ca13c0037ded"
  subscription_id          = "/subscriptions/060a97ea-3a57-4218-9be5-dba3f19ff2b5"
}
