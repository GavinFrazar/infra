locals {
  name  = "gavin"
  namespace = "${local.name}-tf"
  my_ip = chomp(data.http.myip.response_body)
  default_tags = {
    origin = "gavin",
    env    = "dev"
  }

  # To change what is enabled by default, you should edit var.enabled.
  # This local var should not be edited.
  enabled = {
    databases-host = lookup(var.enabled, "databases-host", false)
    kube           = lookup(var.enabled, "kube", false)
    azure-mysql    = lookup(var.enabled, "azure-mysql", false)
  }
}
