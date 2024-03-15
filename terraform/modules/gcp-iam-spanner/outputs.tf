output "access_service_account" {
  description = "The service account that Teleport db_service should assume."
  value       = try(google_service_account.controller[0].email, "")
}

output "admin_user_service_account" {
  description = "Service account for a Spanner admin user."
  value       = try(google_service_account.admin_user[0].email, "")
}

output "user_service_account" {
  description = "Service account for a Spanner user."
  value       = try(google_service_account.user[0].email, "")
}
