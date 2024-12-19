output "gcloud_controller_service_account" {
  description = "The service account that can impersonate other service accounts for testing gcloud cli."
  value       = try(google_service_account.gcloud_controller[0].email, "")
}

output "spanner_access_service_account" {
  description = "The service account that Teleport db_service should assume."
  value       = try(google_service_account.spanner_controller[0].email, "")
}

output "spanner_admin_user_service_account" {
  description = "Service account for a Spanner admin user."
  value       = try(google_service_account.spanner_admin_user[0].email, "")
}

output "spanner_user_service_account" {
  description = "Service account for a Spanner user."
  value       = try(google_service_account.spanner_user[0].email, "")
}
