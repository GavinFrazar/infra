data "aws_iam_policy_document" "this" {
  count = var.create ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_domain}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_domain}:sub"
      values   = ["system:serviceaccount:${var.kube_sa}"]
    }
  }
}
