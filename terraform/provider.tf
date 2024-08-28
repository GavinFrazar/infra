provider "aws" {
  # use US West Oregon for min capacity redshift
  # region  = "us-west-2"
  # or use Canadian for VPC slots
  region  = "ca-central-1"
  profile = "teleport-dev-2"

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
    config_path    = "~/.kube/config"
    config_context = "gavin-tf-eks"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "gavin-tf-eks"
}
