output "postgres_instance_arn" {
  description = "The ARN of the RDS PostgreSQL instance"
  value       = one(module.postgres[*].db_instance_arn)
}

output "postgres_instance_address" {
  description = "The address of the RDS Postgres instance"
  value       = one(module.postgres[*].db_instance_address)
}

output "postgres_master_user_secret_arn" {
  description = "The Secrets Manager ARN for the master user and password of the RDS Postgres instance"
  value       = one(module.postgres[*].db_instance_master_user_secret_arn)
}
