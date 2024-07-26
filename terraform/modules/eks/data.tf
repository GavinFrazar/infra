data "aws_region" "current" {
  count = var.create ? 1 : 0
}

data "aws_iam_policy_document" "trust_ec2" {
  count = var.create ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "trust_eks" {
  count = var.create ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_eks_cluster_auth" "this" {
  count = var.create ? 1 : 0

  name = one(aws_eks_cluster.this[*].id)
}

data "tls_certificate" "eks_oidc_issuer" {
  count = var.create ? 1 : 0

  url = local.oidc_issuer_url
}
