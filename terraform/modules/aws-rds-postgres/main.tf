module "aurora" {
  count   = var.create ? 1 : 0
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.10.0"

  name                                = "${var.name_prefix}-pg-aurora"
  master_username                     = var.db_master_user
  manage_master_user_password         = true
  iam_database_authentication_enabled = true

  engine         = "aurora-postgresql"
  engine_version = "14.9"
  instance_class = "db.t4g.medium"
  instances = {
    one = {}
    two = {}
  }
  port                = var.postgres_port
  publicly_accessible = local.allow_public_access

  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = aws_security_group.postgres[*].id

  apply_immediately            = true
  performance_insights_enabled = false
  storage_encrypted            = true

  create_cloudwatch_log_group = false
  create_db_subnet_group      = false
  create_monitoring_role      = false
  create_security_group       = false

  tags = var.tags
}

module "postgres" {
  count   = var.create ? 1 : 0
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.1"

  identifier                          = "${var.name_prefix}-rds-postgres-instance"
  username                            = var.db_master_user
  manage_master_user_password         = true
  iam_database_authentication_enabled = true
  allow_major_version_upgrade         = true

  engine               = "postgres"
  engine_version       = "16"
  major_engine_version = "16"         # DB option group
  family               = "postgres16" # DB parameter group
  instance_class       = "db.t4g.small"

  storage_type          = "gp3"
  allocated_storage     = 20
  max_allocated_storage = 20

  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = aws_security_group.postgres[*].id
  publicly_accessible    = local.allow_public_access
  port                   = var.postgres_port
  multi_az               = false

  apply_immediately   = true
  skip_final_snapshot = true
  storage_encrypted   = true

  performance_insights_enabled = false
  create_monitoring_role       = false
  create_cloudwatch_log_group  = false

  tags = var.tags
}

# -- postgres db security group and rules --
resource "aws_security_group" "postgres" {
  count = var.create ? 1 : 0

  description = "RDS Postgres security group"
  name        = "${var.name_prefix}-postgres-sg"
  tags        = merge(var.tags, { "Name" : "${var.name_prefix}-postgres-sg" })
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_public_db_access" {
  for_each = var.create ? local.allow_public_access_from_cidrs : []

  cidr_ipv4         = each.value
  from_port         = var.postgres_port
  ip_protocol       = "tcp"
  security_group_id = one(aws_security_group.postgres[*].id)
  to_port           = var.postgres_port
}

resource "aws_vpc_security_group_ingress_rule" "allow_compute" {
  count = var.create ? 1 : 0

  from_port   = var.postgres_port
  ip_protocol = "tcp"
  # reference SG is referred to in the rule itself.
  referenced_security_group_id = one(aws_security_group.compute[*].id)
  # this is the security group to attach the rule to.
  security_group_id = one(aws_security_group.postgres[*].id)
  to_port           = var.postgres_port
}

# -- compute resources security group and rules --
resource "aws_security_group" "compute" {
  count = var.create ? 1 : 0

  description = "Security group for compute resources that need to access postgres"
  name        = "${var.name_prefix}-pg-compute-sg"
  tags        = merge(var.tags, { "Name" : "${var.name_prefix}-pg-compute-sg" })
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

resource "aws_vpc_security_group_egress_rule" "allow_postgres" {
  count = var.create ? 1 : 0

  from_port   = var.postgres_port
  ip_protocol = "tcp"
  # reference SG is referred to in the rule itself.
  referenced_security_group_id = one(aws_security_group.postgres[*].id)
  # this is the security group to attach the rule to.
  security_group_id = one(aws_security_group.compute[*].id)
  to_port           = var.postgres_port
}
