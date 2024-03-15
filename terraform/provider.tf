provider "aws" {
  # use US West Oregon for min capacity redshift
  region  = "us-west-2"

  default_tags {
    tags = local.default_tags
  }
}

provider "google" {
  project = "teleport-dev-320620"
  region  = "us-west1"
  zone    = "us-west1-c"

  default_labels = local.default_tags
}
