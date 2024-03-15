data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_availability_zones" "this" {}

data "aws_caller_identity" "this" {}

data "aws_partition" "this" {}

data "google_project" "this" {}

data "google_client_openid_userinfo" "this" {}
