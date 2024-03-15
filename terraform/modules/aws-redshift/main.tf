resource "aws_redshift_cluster" "this" {
  count = var.create ? 1 : 0

  cluster_identifier     = "${var.namespace}-redshift-cluster"
  database_name          = "dev"
  master_username        = "admin"
  manage_master_password = true
  node_type              = "dc2.large"
  cluster_type           = "single-node"
  skip_final_snapshot    = true
  publicly_accessible    = true
  tags = {
    "teleport.dev/matcher_type" = "redshift"
  }
}
