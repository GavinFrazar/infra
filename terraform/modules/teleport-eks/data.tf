data "aws_route53_zone" "this" {
  count = var.create ? 1 : 0

  name = "devteleport.com"
}

data "kubernetes_ingress" "teleport" {
  for_each = var.create ? local.namespaces : {}

  metadata {
    name = "${helm_release.teleport_cluster[each.key].name}-proxy"
    namespace = each.value
  }
}

data "aws_lb" "teleport" {
  for_each = helm_release.teleport_cluster

  tags = {
    "elbv2.k8s.aws/cluster" = var.eks_cluster_name
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "ingress.k8s.aws/stack" = "${each.value.namespace}/${each.value.name}-proxy"
  }
}
