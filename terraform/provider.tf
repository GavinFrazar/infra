provider "aws" {
  # use US West Oregon for min capacity redshift
  # region  = "us-west-2"
  # or use Canadian for VPC slots
  region = "ca-central-1"

  default_tags {
    tags = local.aws_default_tags
  }
}

provider "google" {
  project = "teleport-dev-320620"
  region  = "us-west1"
  zone    = "us-west1-c"

  default_labels = local.gcp_default_tags
}

provider "null" {}

provider "helm" {
  kubernetes {
    # cluster_ca_certificate = base64decode(module.eks.certificate_authority_data)
    # host                   = module.eks.endpoint
    # token                  = module.eks.cluster_auth_token
    config_path    = "~/.kube/config"
    config_context = "arn:aws:eks:ca-central-1:651149123960:cluster/gavin-tf-eks"
  }
}

provider "kubernetes" {
  # cluster_ca_certificate = base64decode(module.eks.certificate_authority_data)
  # host                   = module.eks.endpoint
  # token                  = module.eks.cluster_auth_token
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:ca-central-1:651149123960:cluster/gavin-tf-eks"
}

# # TODO(gavin): k config rename-context <old> <new> and then change these.
# # I don't want to use such a lengthy name and depend on region in it.
# provider "kubernetes" {
# }
