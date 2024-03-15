locals {
  access_name    = "${var.namespace}-rds-access"
  discovery_name = "${var.namespace}-rds-discovery"


  # need this to break the cyclic dependency in the access role permission boundary.
  access_role_arn = (
    "arn:${var.aws_partition}:iam::${var.aws_account_id}:role/${local.access_name}"
  )
}
