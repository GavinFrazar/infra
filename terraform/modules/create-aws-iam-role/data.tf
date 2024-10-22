data "aws_iam_policy_document" "trust" {
  count = var.create ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.trust_policy_principals
    }
  }

  dynamic "statement" {
    for_each = var.trust_session_tags ? [1] : []
    content {
      actions = ["sts:TagSession"]
      principals {
        type        = "AWS"
        identifiers = var.trust_policy_principals
      }
    }
  }
}
