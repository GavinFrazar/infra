locals {
  helm_release_name    = "teleport"
  service_account_name = "teleport"
  # namespaces
  dns_zone = try(data.aws_route53_zone.this[0].name, "")
  clusters = {
    "alpha" = {
      helm_chart_version = "17.2.6"
      service_type       = "alb"
    }
    "beta" = {
      helm_chart_version = "17.2.6"
      service_type       = "nlb"
    }
  }
  cluster_fqdn = {
    for name, _ in local.clusters : name => "${name}.${local.dns_zone}"
  }
  cluster_namespaces = {
    for name, _ in local.clusters : name => "${name}-devteleport-com"
  }
  needs_acm_certs = toset(["alpha", "beta"]) # TODO: provision acm certs using this list of names.

  license_dir = "~/code/dev/secrets/teleport-licenses"
  license_pem = file("${local.license_dir}/license-all-features.pem")

  hosted_zone_ids = {
    "devteleport.com" = "Z0470569HNIGRA6FOGBH"
  }
  # hardcoded to a hosted zone in teleport-dev-2 account.
  hosted_zone           = "devteleport.com"
  tags_annotation_value = join(",", [for k, v in var.tags : "${k}=${v}"])

  release_image = "public.ecr.aws/gravitational/teleport-ent-distroless-debug"
  staging_image = "public.ecr.aws/gravitational-staging/teleport-ent-distroless-debug"

  cluster_values = var.create ? {
    alpha = <<EOF
clusterName: ${local.cluster_fqdn["alpha"]}
proxyListenerMode: multiplex

# ingress
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
rbac:
  # Specifies whether a ClusterRole and ClusterRoleBinding should be created.
  # Set to false if your cluster level resources are managed separately.
  create: false
# Kubernetes service account to create/use.
serviceAccount:
  # Specifies whether a ServiceAccount should be created
  create: true
  # The name of the ServiceAccount to use.
  # If not set and serviceAccount.create is true, the name is generated using the release name.
  # If create is false, the name will be used to reference an existing service account.
  name: "${local.service_account_name}"

enterprise: true
enterpriseImage: ${local.release_image}
teleportVersionOverride: ""
# Optional array of imagePullSecrets, to use when pulling from a private registry
imagePullSecrets: []
imagePullPolicy: Always

auth:
  extraLabels:
    deployment:
      role: "auth"
    pod:
      role: "auth"

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
    alb.ingress.kubernetes.io/tags: ${local.tags_annotation_value}
    alb.ingress.kubernetes.io/target-type: ip

proxy:
  highAvailability:
    replicaCount: 1
  extraLabels:
    deployment:
      role: "proxy"
    pod:
      role: "proxy"
EOF

    beta = <<EOF
clusterName: ${local.cluster_fqdn["beta"]}
proxyListenerMode: "multiplex"

# ingress
acme: false
acmeEmail: "gavin.frazar@goteleport.com"
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

enterprise: true
enterpriseImage: ${local.release_image}
teleportVersionOverride: ""
# Optional array of imagePullSecrets, to use when pulling from a private registry
imagePullSecrets: []
imagePullPolicy: Always
rbac:
  # Specifies whether a ClusterRole and ClusterRoleBinding should be created.
  # Set to false if your cluster level resources are managed separately.
  create: false

# Kubernetes service account to create/use.
serviceAccount:
  # Specifies whether a ServiceAccount should be created
  create: true
  # The name of the ServiceAccount to use.
  # If not set and serviceAccount.create is true, the name is generated using the release name.
  # If create is false, the name will be used to reference an existing service account.
  name: "${local.service_account_name}"

auth:
  extraLabels:
    deployment:
      role: "auth"
    pod:
      role: "auth"

proxy:
  annotations:
    service:
      service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: "${local.tags_annotation_value}"
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "ssl"
      service.beta.kubernetes.io/aws-load-balancer-ip-address-type: "ipv4"
      service.beta.kubernetes.io/aws-load-balancer-manage-backend-security-group-rules: "true"
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance"
      service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${try(aws_acm_certificate.beta[0].arn, "")}"
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
      service.beta.kubernetes.io/aws-load-balancer-type: "external"
  highAvailability:
    replicaCount: 1
  certManager:
    enabled: false
  extraLabels:
    deployment:
      role: "proxy"
    pod:
      role: "proxy"
EOF
  } : {}
}
