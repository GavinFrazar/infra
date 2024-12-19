output "arn" {
  description = "The created role's arn."
  value       = try(aws_iam_role.this[0].arn, "")
}

output "name" {
  description = "The created role's name."
  value       = try(aws_iam_role.this[0].name, "")
}
