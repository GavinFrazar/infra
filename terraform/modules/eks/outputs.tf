output "aws_iam_oidc_provider_arn" {
  value = local.oidc_provider_arn
}

output "certificate_authority_data" {
  value = try(aws_eks_cluster.this[0].certificate_authority[0].data, "")
}

output "endpoint" {
  value = try(aws_eks_cluster.this[0].endpoint, "")
}

output "id" {
  value = try(aws_eks_cluster.this[0].id, "")
}

output "oidc_domain" {
  value = local.oidc_domain
}

output "oidc_issuer_url" {
  value = local.oidc_issuer_url
}
