data "aws_iam_policy_document" "trust" {
  count = var.create ? 1 : 0

  dynamic "statement" {
    for_each = length(var.trust_policy_principals) > 0 ? [1] : []
    content {
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = sort(var.trust_policy_principals)
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.trust_policy_services) > 0 ? [1] : []
    content {
      actions = ["sts:AssumeRole"]

      principals {
        type = "Service"
        identifiers = sort([
          for svc in var.trust_policy_services :
          "${svc}.amazonaws.com"
        ])
      }
    }
  }

  dynamic "statement" {
    for_each = local.allow_oidc_federation ? [1] : []
    content {
      actions = ["sts:AssumeRoleWithWebIdentity"]

      principals {
        type        = "Federated"
        identifiers = sort(var.trust_policy_oidc_providers)
      }

      dynamic "condition" {
        for_each = var.trust_policy_oidc_conditions
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  dynamic "statement" {
    for_each = var.trust_session_tags ? [1] : []
    content {
      actions = ["sts:TagSession"]
      principals {
        type        = "AWS"
        identifiers = sort(var.trust_policy_principals)
      }
    }
  }
}
