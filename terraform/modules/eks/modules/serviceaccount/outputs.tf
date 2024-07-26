output "role" {
  value = one(aws_iam_role.this[*])
}
