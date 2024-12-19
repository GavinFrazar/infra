output "db_access_role" {
  description = "The role that Teleport db_service should assume."
  value       = module.db_access
}

output "db_discovery_role" {
  description = "The role that Teleport discovery_service should assume."
  value       = module.db_discovery
}

output "integration_roles" {
  description = "Integration roles for Teleport cluster integrations."
  value       = module.teleport_integration_role
}

output "integration_db_svc_roles" {
  description = "Integration roles for Teleport cluster database service integrations."
  value       = module.teleport_integration_db_svc_role
}

output "tester_role" {
  description = "The permissions tester role."
  value       = module.tester
}
