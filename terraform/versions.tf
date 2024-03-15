terraform {
  required_version = ">= 1.0"
  backend "s3" {
    key = "global/s3/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
