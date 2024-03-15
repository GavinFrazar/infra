output "instance_name" {
  value = one(google_spanner_instance.this[*].name)
}

output "googlesql_db" {
  value = one(google_spanner_database.googlesql[*].id)
}

output "postgresql_db" {
  value = one(google_spanner_database.postgresql[*].id)
}
