data "aws_route53_zone" "this" {
  count = var.create ? 1 : 0

  name = "devteleport.com"
}

data "aws_lb" "teleport" {
  for_each = var.create ? local.cluster_namespaces : {}

  tags = {
    "elbv2.k8s.aws/cluster" = var.eks_cluster_name
    # TODO: try to do this in a cleaner way. it's awful right now.
    (local.clusters[each.key].service_type == "alb" ?
      "ingress.k8s.aws/resource" :
      "service.k8s.aws/resource"
    ) = "LoadBalancer"
    (local.clusters[each.key].service_type == "alb" ?
      "ingress.k8s.aws/stack" :
      "service.k8s.aws/stack"
      ) = (local.clusters[each.key].service_type == "alb" ?
      "${each.value}/${helm_release.teleport_cluster[each.key].name}-proxy" :
      "${each.value}/${helm_release.teleport_cluster[each.key].name}"
    )
  }
}
