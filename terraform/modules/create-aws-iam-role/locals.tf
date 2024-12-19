locals {
  permission_policy_arns = var.create ? var.permission_policy_arns : []

  allow_oidc_federation = length(var.trust_policy_oidc_providers) > 0 && length(var.trust_policy_oidc_conditions) > 0
}
