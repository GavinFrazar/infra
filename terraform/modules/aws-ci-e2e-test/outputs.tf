output "gha_db_admin_role_arn" {
  value = module.gha_db_admin.role_arn
}

output "databases_ci" {
  value = one(module.databases_ci[*])
}
