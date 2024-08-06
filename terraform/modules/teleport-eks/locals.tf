locals {
  # namespaces
  dns_zone = one(data.aws_route53_zone.this[*].name)
  clusters = {
    "alpha" = {
      helm_chart_version = "16.0.4"
      service_type       = "alb"
    }
    "beta" = {
      helm_chart_version = "14.3.3"
      service_type       = "nlb"
    }
  }
  cluster_fqdn = {
    for name, _ in local.clusters : name => "${name}.${local.dns_zone}"
  }
  cluster_namespaces = {
    for name, _ in local.clusters : name => "${name}-cluster"
  }
  needs_acm_certs = toset(["alpha", "beta"]) # TODO: provision acm certs using this list of names.

  license_dir = "~/code/dev/secrets/teleport-licenses"
  license_pem = file("${local.license_dir}/license-all-features.pem")

  hosted_zone_ids = {
    "devteleport.com" = "Z0470569HNIGRA6FOGBH"
  }
  # hardcoded to a hosted zone in teleport-dev-2 account.
  hosted_zone = "devteleport.com"
  # TODO: update the alpha cluster tag annotations to just pass var.tags.
  tags_annotation_value = join(",", [for k, v in var.tags : "${k}=${v}"])

  cluster_values = {
    "alpha" = <<EOF
clusterName: ${local.cluster_fqdn["alpha"]}
proxyListenerMode: multiplex

# ingress
annotations:
  ingress:
    alb.ingress.kubernetes.io/backend-protocol: HTTPS
    alb.ingress.kubernetes.io/certificate-arn: ${try(aws_acm_certificate.alpha[0].arn, "")}
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/load-balancer-attributes: idle_timeout.timeout_seconds=350
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/success-codes: 200,301,302
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/tags: ${local.tags_annotation_value}
ingress:
  enabled: true
  spec:
    ingressClassName: alb
service:
  type: ClusterIP

log:
  # Log level for the Teleport process.
  # Available log levels are: DEBUG, INFO, WARNING, ERROR.
  # The default is INFO, which is recommended in production.
  # DEBUG is useful during first-time setup or to see more detailed logs for debugging.
  level: DEBUG
podSecurityPolicy:
  enabled: false

auth:
  extraLabels:
    deployment:
      role: "auth"
    pod:
      role: "auth"
proxy:
  highAvailability:
    replicaCount: 1
  extraLabels:
    deployment:
      role: "proxy"
    pod:
      role: "proxy"

enterprise: true
enterpriseImage: ${var.ecr_repo}
# enterpriseImage: public.ecr.aws/gravitational/teleport-ent-distroless-debug
# Optional array of imagePullSecrets, to use when pulling from a private registry
imagePullSecrets: []
# teleportVersionOverride: ""
teleportVersionOverride: "17.0.0-dev"
imagePullPolicy: Always
EOF

    "beta" = <<EOF
clusterName: ${local.cluster_fqdn["beta"]}
proxyListenerMode: "separate"

# ingress
# acme: true
# acmeEmail: "gavin.frazar@goteleport.com"
annotations:
  service:
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance"
    service.beta.kubernetes.io/aws-load-balancer-internal: "false"
    service.beta.kubernetes.io/aws-load-balancer-ip-address-type: "ipv4"
    service.beta.kubernetes.io/aws-load-balancer-manage-backend-security-group-rules: "true"
    service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: "${local.tags_annotation_value}"
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${try(aws_acm_certificate.beta[0].arn, "")}"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "ssl"
ingress:
  enabled: false
  # spec:
  #   ingressClassName: alb
service:
  type: LoadBalancer

log:
  # Log level for the Teleport process.
  # Available log levels are: DEBUG, INFO, WARNING, ERROR.
  # The default is INFO, which is recommended in production.
  # DEBUG is useful during first-time setup or to see more detailed logs for debugging.
  level: DEBUG
podSecurityPolicy:
  enabled: false

auth:
  extraLabels:
    deployment:
      role: "auth"
    pod:
      role: "auth"
proxy:
  highAvailability:
    replicaCount: 1
  certManager:
    enabled: false
  extraLabels:
    deployment:
      role: "proxy"
    pod:
      role: "proxy"

enterprise: true
# enterpriseImage: ${var.ecr_repo}
enterpriseImage: public.ecr.aws/gravitational/teleport-ent-distroless-debug
# Optional array of imagePullSecrets, to use when pulling from a private registry
imagePullSecrets: []
teleportVersionOverride: ""
# teleportVersionOverride: "17.0.0-dev"
imagePullPolicy: Always
EOF
  }
}
