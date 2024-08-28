resource "kubernetes_namespace" "teleport_cluster" {
  for_each = var.create ? local.cluster_namespaces : {}

  metadata {
    name = each.value
  }
}

resource "kubernetes_secret" "license" {
  for_each = var.create ? local.cluster_namespaces : {}

  metadata {
    name      = "license"
    namespace = each.value
  }

  data = {
    "license.pem" = local.license_pem
  }

  depends_on = [kubernetes_namespace.teleport_cluster]
}

resource "helm_release" "teleport_cluster" {
  for_each = var.create ? local.cluster_namespaces : {}

  # uncomment this to use a local checkout of the helm chart, but avoid doing it
  # because it couples the release to your local git repo's HEAD.
  # chart = pathexpand("~/code/teleport/examples/chart/teleport-cluster")
  chart      = "teleport-cluster"
  name       = each.key
  repository = "https://charts.releases.teleport.dev"
  version    = local.clusters[each.key].helm_chart_version

  atomic          = true # purge the release on fail.
  cleanup_on_fail = true
  namespace       = each.value
  values          = [local.cluster_values[each.key]]
  wait            = true # waits for all deployed resources to be in a ready state (the default).

  depends_on = [
    kubernetes_namespace.teleport_cluster,
    kubernetes_secret.license,
  ]
}

// some deployments I might want to use L4 LB with LetsEncrypt certs, in which
// case I don't need an AWC ACM cert.
resource "aws_acm_certificate" "alpha" {
  count = var.create ? 1 : 0

  domain_name               = local.cluster_fqdn["alpha"]
  validation_method         = "DNS"
  subject_alternative_names = ["*.${local.cluster_fqdn["alpha"]}"]
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alpha"
  })

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "alpha_validation" {
  for_each = var.create ? {
    for dvo in aws_acm_certificate.alpha[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = one(data.aws_route53_zone.this[*].zone_id)
}

resource "aws_acm_certificate_validation" "alpha" {
  count = var.create ? 1 : 0

  certificate_arn = one(aws_acm_certificate.alpha[*].arn)
  validation_record_fqdns = [
    for record in aws_route53_record.alpha_validation :
    record.fqdn
  ]
}

resource "aws_route53_record" "teleport_ingress" {
  for_each = data.aws_lb.teleport

  name    = each.key
  type    = "A"
  zone_id = local.hosted_zone_ids[local.hosted_zone]

  alias {
    name                   = "dualstack.${each.value.dns_name}"
    zone_id                = each.value.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "teleport_app_ingress" {
  for_each = data.aws_lb.teleport

  name    = "*.${each.key}"
  type    = "A"
  zone_id = local.hosted_zone_ids[local.hosted_zone]

  alias {
    name                   = "dualstack.${each.value.dns_name}"
    zone_id                = each.value.zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "beta" {
  count = var.create ? 1 : 0

  domain_name               = local.cluster_fqdn["beta"]
  validation_method         = "DNS"
  subject_alternative_names = ["*.${local.cluster_fqdn["beta"]}"]
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-beta"
  })

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "beta_validation" {
  for_each = var.create ? {
    for dvo in aws_acm_certificate.beta[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = one(data.aws_route53_zone.this[*].zone_id)
}

resource "aws_acm_certificate_validation" "beta" {
  count = var.create ? 1 : 0

  certificate_arn = one(aws_acm_certificate.beta[*].arn)
  validation_record_fqdns = [
    for record in aws_route53_record.beta_validation :
    record.fqdn
  ]
}
