variable "enabled" {
  description = "Submodules that are enabled by default."
  type        = map(bool)
  default = {
    databases-host = false
    kube           = false
    azure-mysql    = false
  }
}
