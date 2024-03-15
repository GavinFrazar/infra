output "role_arn" {
  description = "The created role's arn."
  value       = try(aws_iam_role.this[0].arn, "")
}

output "role_name" {
  description = "The created role's name."
  value       = try(aws_iam_role.this[0].name, "")
}
