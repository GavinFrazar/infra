locals {
  allow_public_access            = length(var.allow_public_access_from_cidrs) > 0
  allow_public_access_from_cidrs = sort(toset(compact(var.allow_public_access_from_cidrs)))
}
