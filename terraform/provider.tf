provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      "origin"                    = "gavin",
      "env"                       = "dev",
    }
  }
}

provider "google" {
  project = "teleport-dev"
  region  = "us-west1"
  zone    = "us-west1-c"

  default_labels = local.default_tags
}
