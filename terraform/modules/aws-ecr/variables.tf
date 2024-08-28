variable "create" {
  type    = bool
  default = true
}

variable "name_prefix" {
  description = "The prefix to use for created resource names"
  type        = string
}
