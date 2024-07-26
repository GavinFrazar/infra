locals {
  # namespaces
  dns_zone = one(data.aws_route53_zone.this[*].name)
  clusters = toset([
    "alpha",
  ])
  clusters_fqdn = {
    for name in local.clusters : name => "${name}.${local.dns_zone}"
  }
  namespaces = {
    for name in local.clusters : name => "${name}-cluster"
  }
  license_dir = "~/code/dev/secrets/teleport-licenses"
  license_pem = file("${local.license_dir}/license-all-features.pem")

  hosted_zone_ids = {
    "devteleport.com" = "Z0470569HNIGRA6FOGBH"
  }
  # hardcoded to a hosted zone in teleport-dev-2 account.
  hosted_zone = "devteleport.com"

  teleport_configs = {
    "alpha" = <<EOF
clusterName: ${local.clusters_fqdn["alpha"]}
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
    alb.ingress.kubernetes.io/tags: teleport.dev/creator=gavin.frazar@goteleport.com
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
    replicaCount: 2
  extraLabels:
    deployment:
      role: "proxy"
    pod:
      role: "proxy"

enterprise: true
enterpriseImage: ${var.ecr_repo}
# enterpriseImage: public.ecr.aws/gravitational/teleport-ent-distroless
# Optional array of imagePullSecrets, to use when pulling from a private registry
imagePullSecrets: []
teleportVersionOverride: "17.0.0-dev"
imagePullPolicy: Always
EOF
  }
}
