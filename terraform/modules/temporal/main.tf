locals {
  kube_namespace    = "temporal"
  tbot_sa_name      = "tbot"
  tbot_iam_role_arn = module.tbot_temporal_irsa.iam_role_arn
  # tbot_iam_role_arn = module.tbot_irsa.role.arn
}

module "tbot_temporal_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  create_role = var.create
  oidc_providers = {
    main = {
      namespace_service_accounts = ["${local.kube_namespace}:${local.tbot_sa_name}"]
      provider_arn               = var.oidc_provider_arn
    }
  }
  role_name = "${local.kube_namespace}-${local.tbot_sa_name}"
}

# unused: only needed this to test connectivity without doing a full temporal
# rollout.
resource "kubernetes_manifest" "temporal_deployment" {
  # TODO: set to 0.
  count = var.create ? 0 : 0

  manifest = yamldecode(<<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: temporal
  namespace: ${local.kube_namespace}
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app.kubernetes.io/name: tbot
  template:
    metadata:
      labels:
        app.kubernetes.io/name: tbot
    spec:
      containers:
        - name: netshoot
          image: nicolaka/netshoot:latest
          command: ["/bin/sh", "-c", "while true; do sleep 100; done"]
          volumeMounts:
            - mountPath: /config
              name: config
            # - name: "db-output"
            #   mountPath: "/db-output"
        - name: psql
          image: postgres:16
          command: ["/bin/sh", "-c", "while true; do sleep 100; done"]
          volumeMounts:
            - name: "tbot-socket"
              mountPath: "/tbot-socket"
        - name: tbot
          image: public.ecr.aws/gravitational/tbot-distroless:16.3.0
          args:
            - start
            - -c
            - /config/tbot.yaml
          volumeMounts:
            - mountPath: /config
              name: config
            - name: "tbot-socket"
              mountPath: "/tbot-socket"
      serviceAccountName: ${local.tbot_sa_name}
      volumes:
        - name: config
          configMap:
            name: tbot
        - name: "tbot-socket"
          emptyDir: {}
EOF
  )
}

# unused: the helm chart can do this, only used to test without temporal rollout.
resource "kubernetes_service_account" "tbot" {
  # TODO: set to 0.
  count = var.create ? 0 : 0

  metadata {
    name      = local.tbot_sa_name
    namespace = local.kube_namespace
    labels = {
      "app.kubernetes.io/component" = "machine-id"
      "app.kubernetes.io/name"      = "tbot"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = local.tbot_iam_role_arn
    }
  }
}

# unused: I will create the namespace with a plain manifest with kubectl.
resource "kubernetes_namespace" "this" {
  count = var.create ? 0 : 0

  metadata {
    name = local.kube_namespace
  }
}

# unused: I will apply this configmap as a plain manifest with kubectl.
resource "kubernetes_manifest" "temporal_cm" {
  count = var.create ? 0 : 0

  manifest = yamldecode(<<-EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: tbot
  namespace: ${local.kube_namespace}
data:
  tbot.yaml: |
    version: v2
    debug: true
    onboarding:
      join_method: iam
      token: temporal-bot
    storage:
      type: memory
    proxy_server: ${var.teleport_cluster_proxy_addr}
    services:
      - type: "database-tunnel"
        listen: "unix:///tbot-socket/gavin-tf-rds-postgres-instance.sock"
        service: gavin-tf-rds-postgres-instance
        database: postgres
        username: temporal
      - type: "database-tunnel"
        listen: "tcp://localhost:5432"
        service: gavin-tf-rds-postgres-instance
        database: postgres
        username: temporal
EOF
  )
}


# unused: we dont need to grant secrets permissions since tbot isnt configured
# to create secrets.
resource "kubernetes_role_v1" "secrets_admin" {
  count = var.create ? 0 : 0

  metadata {
    name      = "secrets-admin"
    namespace = local.kube_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["*"]
  }
}

# unused: we dont need to grant secrets permissions since tbot isnt configured
# to create secrets.
resource "kubernetes_role_binding_v1" "tbot_secrets_admin" {
  count = var.create ? 0 : 0

  metadata {
    name      = "tbot-secrets-admin"
    namespace = local.kube_namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    name      = try(kubernetes_role_v1.secrets_admin[0].metadata[0].name, "")
    kind      = "Role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = try(kubernetes_service_account.tbot[0].metadata[0].name, "")
    namespace = local.kube_namespace
  }
}

# unused: while I prefer my own modules, I need something I can easily show in a
# blog post.
module "tbot_irsa" {
  create = false # var.create
  source = "../eks/modules/serviceaccount"

  role_name         = "${var.name_prefix}-${local.kube_namespace}-${local.tbot_sa_name}"
  kube_sa           = "${local.kube_namespace}:${local.tbot_sa_name}"
  oidc_domain       = var.oidc_domain
  oidc_provider_arn = var.oidc_provider_arn
  tags              = var.tags
}
