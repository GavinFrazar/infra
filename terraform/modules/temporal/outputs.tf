output "tbot_role_arn" {
  value = try(local.tbot_iam_role_arn, "")
}
