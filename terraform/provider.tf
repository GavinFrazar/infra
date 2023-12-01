provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      "origin"                    = "gavin",
      "env"                       = "dev",
    }
  }
}
