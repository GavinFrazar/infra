output "role_arn" {
  description = "Role ARN for the db user."
  value       = module.db_user.role_arn
}
