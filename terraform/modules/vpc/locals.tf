locals {
  azs             = slice(compact(sort(var.az_names)), 0, 2)
  subnet_cidr_gap = 10
  prefix_ext      = 8
}
