module "addons" {
  source = "./modules/addons"

  cluster_name      = one(aws_eks_cluster.this[*].id)
  create            = var.create && var.create_addons
  name_prefix       = var.name_prefix
  oidc_domain       = local.oidc_domain
  oidc_provider_arn = local.oidc_provider_arn
  tags              = var.tags
  vpc_id            = var.vpc_id

  depends_on = [
    // since this provisions kube objects
    aws_eks_access_policy_association.cluster_admin,
  ]
}

# setup the EKS cluster
resource "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "scheduler"
  ]
  name     = local.cluster_name
  role_arn = try(aws_iam_role.eks_cluster[0].arn, "")
  tags     = var.tags
  version  = var.cluster_version

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = false
  }

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "10.42.0.0/16"
  }

  vpc_config {
    endpoint_private_access = true # TODO: set to false
    endpoint_public_access  = true # TODO: set to false after deploying teleport.
    public_access_cidrs     = local.public_access_ip_ranges
    security_group_ids      = aws_security_group.this[*].id
    subnet_ids              = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.registry,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.eks_cluster,
  ]
}

# setup an IAM OIDC connect provider for pod AWS credentials
resource "aws_iam_openid_connect_provider" "this" {
  count = var.create ? 1 : 0

  url            = local.oidc_issuer_url
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    # important: only trust the root CA (the first cert in the chain is root).
    try(data.tls_certificate.eks_oidc_issuer[0].certificates[0].sha1_fingerprint, "")
  ]
}

# this can't be relied on for providers, because the provider loads kubeconfig
# before this runs.
resource "null_resource" "kubeconfig" {
  count = var.create ? 1 : 0

  triggers = {
    cluster_id = try(aws_eks_cluster.this[0].id, "")
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
set -e
echo 'Updating ~/.kube/config'
aws eks wait cluster-active \
  --name '${local.cluster_name}' \
  --profile '${local.aws_profile}' \
  --region '${local.region}'
aws eks update-kubeconfig \
  --name '${local.cluster_name}' \
  --profile '${local.aws_profile}' \
  --region '${local.region}' \
  --alias '${local.cluster_name}'
EOF
  }

  depends_on = [
    aws_eks_cluster.this
  ]
}

resource "aws_eks_access_entry" "cluster_admin" {
  for_each = var.create ? local.cluster_admin_arns : toset([])

  cluster_name  = one(aws_eks_cluster.this[*].id)
  principal_arn = each.value
  // not allowed to grant groups starting with "system:", so I'll use an EKS
  // access policy association instead for cluster admin.
  kubernetes_groups = []
  tags              = var.tags
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_admin" {
  for_each = var.create ? local.cluster_admin_arns : toset([])

  cluster_name  = one(aws_eks_cluster.this[*].id)
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.cluster_admin,
  ]
}

# NOTE: this is the "additional security group" for the EKS cluster, which
# controls communication between the control plane and compute resources
# in AWS. I can use this to attach additional rules since it takes 10+ minutes
# to attach/detach this SG otherwise.
resource "aws_security_group" "this" {
  count = var.create ? 1 : 0

  name        = "${var.name_prefix}-eks-sg"
  description = "EKS cluster API security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eks-sg"
  })
}

# setup IAM for the control plane
resource "aws_iam_role" "eks_cluster" {
  count = var.create ? 1 : 0

  name                 = "${var.name_prefix}-eks-cluster"
  assume_role_policy   = one(data.aws_iam_policy_document.trust_eks[*].json)
  max_session_duration = 3600

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  count = var.create ? 1 : 0

  role       = one(aws_iam_role.eks_cluster[*].name)
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# setup worker nodes
resource "aws_eks_node_group" "this" {
  count = var.create ? 1 : 0

  # for defaults below, I just want drift detection.
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND" # default
  cluster_name    = aws_eks_cluster.this[0].id
  node_group_name = "${var.name_prefix}-node-group"
  node_role_arn   = aws_iam_role.node[0].arn
  subnet_ids      = var.subnet_ids
  tags            = var.tags

  launch_template {
    id      = one(aws_launch_template.this[*].id)
    version = coalesce(one(aws_launch_template.this[*].default_version), "$Default")
  }

  scaling_config {
    desired_size = length(var.subnet_ids)
    max_size     = 7
    min_size     = length(var.subnet_ids)
  }

  update_config {
    # I dont care if the entire worker pool goes down for update.
    max_unavailable_percentage = 100
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.registry,
    aws_iam_role_policy_attachment.cni,
  ]
}

resource "aws_launch_template" "this" {
  count = var.create ? 1 : 0

  name_prefix   = var.name_prefix
  ebs_optimized = true
  # image_id      = local.launch_amis["teleport-dev-2"]["ca-central-1"]
  instance_type = "t3.medium"
  # user_data     = local.user_data

  network_interfaces {
    # if this is true, then the node subnet(s) need a rotue to an IGW.
    # if false, then the node subnet(s) need a route to a NAT gateway.
    associate_public_ip_address = true
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag_specifications" {
    for_each = ["instance", "volume", "network-interface", "spot-instances-request"]
    content {
      resource_type = tag_specifications.value
      tags          = var.tags
    }
  }

  metadata_options {
    # Despite being documented as "Optional", `http_endpoint` is required when `http_put_response_hop_limit` is set.
    # We set it to the default setting of "enabled".
    # Copied from: https://github.com/cloudposse/terraform-aws-eks-node-group/blob/main/launch-template.tf
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
    # if I enable this, it disallows tag keys with "/" in it, breaking the
    # "teleport.dev/creator" tag.
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html#tag-restrictions
    instance_metadata_tags = "disabled"
  }
}

# setup IAM role for the workers
resource "aws_iam_role" "node" {
  count = var.create ? 1 : 0

  name                 = "${var.name_prefix}-eks-node"
  assume_role_policy   = one(data.aws_iam_policy_document.trust_ec2[*].json)
  max_session_duration = 3600

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "worker" {
  count = var.create ? 1 : 0

  role       = one(aws_iam_role.node[*].name)
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "registry" {
  count = var.create ? 1 : 0

  role       = one(aws_iam_role.node[*].name)
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cni" {
  count = var.create ? 1 : 0

  role       = one(aws_iam_role.node[*].name)
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
