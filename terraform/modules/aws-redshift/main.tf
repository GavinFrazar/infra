resource "aws_redshift_cluster" "this" {
  count = var.create ? 1 : 0

  automated_snapshot_retention_period = 0 # disable snapshots
  cluster_identifier                  = "${var.name_prefix}-redshift-cluster"
  cluster_parameter_group_name        = one(aws_redshift_parameter_group.this[*].id)
  cluster_subnet_group_name           = one(aws_redshift_subnet_group.this[*].id)
  cluster_type                        = "single-node"
  database_name                       = "dev"
  encrypted                           = true
  manage_master_password              = true
  master_username                     = "admin"
  multi_az                            = false
  node_type                           = "dc2.large"
  publicly_accessible                 = local.allow_public_access
  skip_final_snapshot                 = true
  tags = merge(var.tags, {
    "teleport.dev/db-admin" = "teleport-admin"
  })
  vpc_security_group_ids = aws_security_group.database[*].id

  logging {
    # This is a test database. There is nothing valuable inside it and audit
    # logging will incur additional expenses.
    enable = false
  }
}

resource "aws_security_group" "database" {
  count = var.create ? 1 : 0

  description = "Redshift cluster security group"
  name        = "${var.name_prefix}-redshift-cluster-sg"
  tags        = merge(var.tags, { "Name" : "${var.name_prefix}-redshift-cluster-sg" })
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_public_db_access" {
  for_each = var.create ? local.allow_public_access_from_cidrs : []

  cidr_ipv4         = each.value
  from_port         = local.port
  ip_protocol       = "tcp"
  security_group_id = one(aws_security_group.database[*].id)
  to_port           = local.port
}

resource "aws_vpc_security_group_ingress_rule" "allow_compute" {
  count = var.create ? 1 : 0

  from_port   = local.port
  ip_protocol = "tcp"
  # reference SG is referred to in the rule itself.
  referenced_security_group_id = one(aws_security_group.compute[*].id)
  # this is the security group to attach the rule to.
  security_group_id = one(aws_security_group.database[*].id)
  to_port           = local.port
}

resource "aws_redshift_parameter_group" "this" {
  count = var.create ? 1 : 0

  name   = "${var.name_prefix}-redshift-params"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    # disable concurrency scaling.
    name  = "max_concurrency_scaling_clusters"
    value = "0"
  }
}

resource "aws_redshift_subnet_group" "this" {
  count = var.create ? 1 : 0

  name       = "${var.name_prefix}-redshift-cluster"
  subnet_ids = var.subnet_ids
}

# -- compute resources security group and rules --
resource "aws_security_group" "compute" {
  count = var.create ? 1 : 0

  description = "Security group for compute resources that need to access the database"
  name        = "${var.name_prefix}-redshift-compute-sg"
  tags        = merge(var.tags, { "Name" : "${var.name_prefix}-redshift-compute-sg" })
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  count = var.create ? 1 : 0

  cidr_ipv4         = "0.0.0.0/0"
  from_port         = "-1"
  ip_protocol       = "-1"
  security_group_id = one(aws_security_group.compute[*].id)
  to_port           = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_database" {
  count = var.create ? 1 : 0

  from_port   = local.port
  ip_protocol = "tcp"
  # reference SG is referred to in the rule itself.
  referenced_security_group_id = one(aws_security_group.database[*].id)
  # this is the security group to attach the rule to.
  security_group_id = one(aws_security_group.compute[*].id)
  to_port           = local.port
}
