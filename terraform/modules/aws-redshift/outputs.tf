output "db_instance_master_user_secret_arn" {
  description = "The Secrets Manager ARN for the master user and password of the database"
  value       = one(aws_redshift_cluster.this[*].master_password_secret_arn)
}

output "endpoint" {
  description = "Redshift cluster endpoint."
  value       = try(aws_redshift_cluster.this[0].endpoint, "")
}
