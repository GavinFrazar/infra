output "access_role_arn" {
  description = "The role that Teleport db_service should assume."
  value       = module.access.role_arn
}

output "discovery_role_arn" {
  description = "The role that Teleport discovery_service should assume."
  value       = module.discovery.role_arn
}
