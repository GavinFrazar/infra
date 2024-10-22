locals {
  account_id = try(data.aws_caller_identity.this[0].account_id, "")
}
