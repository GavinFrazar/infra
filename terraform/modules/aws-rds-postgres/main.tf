module "postgres" {
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
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.allow_public_access
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
