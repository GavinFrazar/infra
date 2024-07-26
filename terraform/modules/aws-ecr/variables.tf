variable "create" {
  type     = bool
  default  = true
  nullable = false
}

variable "name_prefix" {
  description = "The prefix to use for created resource names"
  type        = string
  nullable    = false
}
