resource "aws_redshiftserverless_namespace" "this" {
  count          = var.create ? 1 : 0
  namespace_name = "${var.namespace}-redshift-serverless-namespace"
  db_name        = "postgres"
  tags = {
    "teleport.dev/matcher_type" = "redshift-serverless"
  }
}

resource "aws_redshiftserverless_workgroup" "this" {
  count          = var.create ? 1 : 0
  workgroup_name = "${var.namespace}-redshift-serverless-workgroup"
  namespace_name = try(aws_redshiftserverless_namespace.this[0].namespace_name, "")

  # Minimal configuration for testing
  base_capacity = 32 # Adjust base capacity as needed, minimum for testing

  # Security and access settings
  enhanced_vpc_routing = false
  publicly_accessible  = var.allow_public_access
  security_group_ids   = var.security_group_ids
  subnet_ids           = var.subnet_ids
  tags = {
    "teleport.dev/matcher_type" = "redshift-serverless"
  }
}
