# setup EBS CSI driver
resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.create ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.31.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = try(aws_iam_role.ebs_csi_driver[0].arn, "")
  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver
  ]
}

resource "aws_iam_role" "ebs_csi_driver" {
  count = var.create ? 1 : 0

  name                 = "${var.name_prefix}-ebs-csi-driver"
  assume_role_policy   = one(data.aws_iam_policy_document.trust_ebs_csi_addon[*].json)
  max_session_duration = 3600

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  count = var.create ? 1 : 0

  role       = one(aws_iam_role.ebs_csi_driver[*].name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# setup LB controller
resource "helm_release" "aws_lb_controller" {
  count = var.create ? 1 : 0

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  # the release name.
  name      = "${var.name_prefix}-aws-load-balancer-controller"
  namespace = "kube-system"
  # waits for all deployed resources to be in a ready state (the default).
  wait = true

  values = [
    <<EOF
clusterName: "${var.cluster_name}"
region: "${try(data.aws_region.current[0].name, "")}"
serviceAccount:
  create: true
  name: "${local.alb_sa_name}"
  annotations:
    "eks.amazonaws.com/role-arn": "${module.lb_controller_irsa.role.arn}"
vpcId: "${var.vpc_id}"
EOF
  ]

  depends_on = [
    aws_iam_role_policy_attachment.lb_controller_irsa,
  ]
}

module "lb_controller_irsa" {
  create = var.create
  source = "../serviceaccount"

  kube_sa           = "kube-system:${local.alb_sa_name}"
  role_name         = "${var.name_prefix}-AmazonEKSLoadBalancerController"
  oidc_domain       = var.oidc_domain
  oidc_provider_arn = var.oidc_provider_arn
  tags              = var.tags
}

resource "aws_iam_policy" "lb_controller_irsa" {
  count = var.create ? 1 : 0

  name        = "${var.name_prefix}-AmazonEKSLoadBalancerController"
  path        = "/"
  description = "IAM policy for EKS LB controller"
  policy      = one(data.aws_iam_policy_document.lb_controller[*].json)

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lb_controller_irsa" {
  count = var.create ? 1 : 0

  role       = module.lb_controller_irsa.role.name
  policy_arn = one(aws_iam_policy.lb_controller_irsa[*].arn)
}
