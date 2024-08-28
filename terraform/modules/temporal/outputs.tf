output "tbot_role_arn" {
  value = try(module.tbot_irsa.role.arn, "")
}
