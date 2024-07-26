locals {
  public_access_ip_ranges = sort(toset(compact(var.public_access_ip_ranges)))
  cluster_admin_arns      = toset(compact(var.cluster_admin_arns))

  # to keep track of the AMI account/region
  launch_amis = {
    "teleport-dev-2" = {
      "ca-central-1" = "ami-057fab3ec2fe013b2"
    }
  }

  oidc_domain       = trimprefix(local.oidc_issuer_url, "https://")
  oidc_issuer_url   = try(aws_eks_cluster.this[0].identity[0].oidc[0].issuer, "")
  oidc_provider_arn = one(aws_iam_openid_connect_provider.this[*].arn)
}
