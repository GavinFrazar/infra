module "postgres" {
  count   = var.create ? 1 : 0
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.1"

  identifier                  = "${var.name_prefix}-rds-postgres-instance"
  username                    = var.db_master_user
  manage_master_user_password = true
  # We need IAM auth enabled at deploy time so we can create an IAM enabled
  # database user.
  iam_database_authentication_enabled = false

  engine               = "postgres"
  engine_version       = "14"
  major_engine_version = "14"         # DB option group
  family               = "postgres14" # DB parameter group
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

resource "aws_vpc_security_group_ingress_rule" "allow_public" {
  for_each = var.create ? local.allow_public_access_from_cidrs : []

  cidr_ipv4         = each.value
  from_port         = var.postgres_port
  ip_protocol       = "tcp"
  security_group_id = one(aws_security_group.postgres[*].id)
  to_port           = var.postgres_port
}

resource "aws_vpc_security_group_ingress_rule" "allow_compute" {
  count = var.create ? 1 : 0

  from_port                    = var.postgres_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = one(aws_security_group.compute[*].id)
  security_group_id            = one(aws_security_group.postgres[*].id)
  to_port                      = var.postgres_port
}

# -- compute resources security group and rules --
resource "aws_security_group" "compute" {
  count = var.create ? 1 : 0

  description = "Security group for compute resources that need to access postgres"
  name        = "${var.name_prefix}-pg-compute-sg"
  tags        = merge(var.tags, { "Name" : "${var.name_prefix}-pg-compute-sg" })
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_ecr" {
  count = var.create ? 1 : 0

  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  security_group_id = one(aws_security_group.compute[*].id)
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_postgres" {
  count = var.create ? 1 : 0

  from_port                    = var.postgres_port
  ip_protocol                  = "tcp"
  referenced_security_group_id = one(aws_security_group.postgres[*].id)
  security_group_id            = one(aws_security_group.compute[*].id)
  to_port                      = var.postgres_port
}
