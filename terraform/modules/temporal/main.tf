module "tbot_irsa" {
  create = var.create
  source = "../eks/modules/serviceaccount"

  role_name         = "${var.name_prefix}-${local.namespace}-${local.tbot_sa_name}"
  kube_sa           = "${local.namespace}:${local.tbot_sa_name}"
  oidc_domain       = var.oidc_domain
  oidc_provider_arn = var.oidc_provider_arn
  tags              = var.tags
}

resource "kubernetes_namespace" "this" {
  count = var.create ? 1 : 0

  metadata {
    name = local.namespace
  }
}

resource "kubernetes_service_account" "tbot" {
  count = var.create ? 1 : 0

  metadata {
    name      = local.tbot_sa_name
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/component" = "machine-id"
      "app.kubernetes.io/name"      = "tbot"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.tbot_irsa.role.arn
    }
  }
}

resource "kubernetes_role_v1" "secrets_admin" {
  count = var.create ? 1 : 0

  metadata {
    name      = "secrets-admin"
    namespace = local.namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding_v1" "tbot_secrets_admin" {
  count = var.create ? 1 : 0

  metadata {
    name      = "tbot-secrets-admin"
    namespace = local.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    name      = try(kubernetes_role_v1.secrets_admin[0].metadata[0].name, "")
    kind      = "Role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = try(kubernetes_service_account.tbot[0].metadata[0].name, "")
    namespace = local.namespace
  }
}

resource "kubernetes_manifest" "temporal_cm" {
  count = var.create ? 1 : 0

  manifest = yamldecode(<<-EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: tbot-config
  namespace: ${local.namespace}
data:
  tbot.yaml: |
    debug: true
    version: v2
    onboarding:
      join_method: iam
      token: temporal-bot
    storage:
      type: memory
    proxy_server: ${var.teleport_cluster_proxy_addr}
    # outputs:
    # - type: database
    #   service: gavin-tf-rds-postgres-instance
    #   database: postgres
    #   username: teleport-admin
    #   destination:
    #     type: kubernetes_secret
    #     name: db-output
    services:
      - type: "database-tunnel"
        listen: "unix:///tbot-sockets/gavin-tf-rds-postgres-instance.sock"
        service: gavin-tf-rds-postgres-instance
        database: postgres
        username: bot-temporal
      - type: "database-tunnel"
        listen: "tcp://localhost:5432"
        service: gavin-tf-rds-postgres-instance
        database: postgres
        username: bot-temporal
EOF
  )
}

# - type: database-tunnel
#   listen: "tcp://127.0.0.1:15432"
#   service: gavin-tf-rds-postgres-instance
#   database: postgres
#   username: teleport-admin # change this to a lesser user. Can it be removed for auto users?

# - type: database
#   destination:
#     type: directory
#     path: /opt/machine-id
#   service: gavin-tf-rds-postgres-instance
#   database: postgres
#   username: teleport-admin # change this to a lesser user. Can it be removed for auto users?

resource "kubernetes_manifest" "temporal_deployment" {
  count = var.create ? 1 : 0

  manifest = yamldecode(<<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: temporal
  namespace: ${local.namespace}
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
            - name: "tbot-sockets"
              mountPath: "/tbot-sockets"
        - name: tbot
          image: public.ecr.aws/gravitational/tbot-distroless:16.0.4
          args:
            - start
            - -c
            - /config/tbot.yaml
          env:
            # POD_NAMESPACE is required for the kubernetes_secret` destination
            # type to work correctly.
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          volumeMounts:
            - mountPath: /config
              name: config
            - name: "tbot-sockets"
              mountPath: "/tbot-sockets"
      serviceAccountName: ${local.tbot_sa_name}
      volumes:
        - name: config
          configMap:
            name: tbot-config
        # - name: "db-output"
        #   secret:
        #     secretName: "db-output"
        - name: "tbot-sockets"
          emptyDir: {}
EOF
  )
}


#             # KUBERNETES_TOKEN_PATH specifies the path to the service account
#             # JWT to use for joining.
#             # This path is based on the configuration of the volume and
#             # volumeMount.
#             # TODO: uncomment this env var when joining with kube join token
#             - name: KUBERNETES_TOKEN_PATH
#               value: /var/run/secrets/tokens/join-sa-token
#           volumeMounts:
#             - mountPath: /config
#               name: config
#             - mountPath: /var/run/secrets/tokens
#               name: join-sa-token
#       serviceAccountName: ${local.tbot_sa_name}
#       volumes:
#         - name: db-output
#           secret:
#             secretName: db-output
#         - name: config
#           configMap:
#             name: tbot-config
#         - name: join-sa-token
#           projected:
#             sources:
#               - serviceAccountToken:
#                   path: join-sa-token
#                   # 600 seconds is the minimum that Kubernetes supports. We
#                   # recommend this value is used.
#                   expirationSeconds: 600
#                   # must be replaced with the name of your teleport cluster,
#                   # e.g. "example.teleport.sh".
#                   audience: ${var.teleport_cluster_name}
# EOF
#   )
# }
