module "self-hosted-databases" {
  source              = "./self-hosted-databases"
  access_keypair_name = "gavin"
  access_from_ip      = local.my_ip

  count = 1
  additional_tags = {
    Name = "self-hosted-databases"
  }
}

