module "postgres" {
  count   = var.create ? 1 : 0
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.1"

  identifier                  = "${var.name_prefix}-rds-postgres-instance"
  username                    = var.db_master_user
  manage_master_user_password = true
  # We need IAM auth enabled at deploy time so we can create an IAM enabled
  # database user.
  iam_database_authentication_enabled = true

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

resource "aws_security_group" "postgres" {
  count = var.create ? 1 : 0

  name        = "${var.name_prefix}-postgres-sg"
  description = "RDS Postgres security group"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  count = var.create ? length(local.allow_public_access_from_cidrs) : 0

  security_group_id = one(aws_security_group.postgres[*].id)
  cidr_ipv4         = local.allow_public_access_from_cidrs[count.index]
  ip_protocol       = "tcp"
  from_port         = var.postgres_port
  to_port           = var.postgres_port
}
