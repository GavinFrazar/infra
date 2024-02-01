module "azure-mysql" {
  count     = local.enabled.azure-mysql ? 1 : 0
  source    = "./azure-mysql"
  namespace = local.namespace
}

module "databases-host" {
  count     = local.enabled.databases-host ? 1 : 0
  source    = "./databases-host"
  namespace = local.namespace

  access_keypair_name = aws_key_pair.ssh-ed25519.key_name
  access_from_ip      = local.my_ip
}

module "kube" {
  count     = local.enabled.kube ? 1 : 0
  source    = "./kube"
  namespace = local.namespace

  access_from_ip = local.my_ip
}
