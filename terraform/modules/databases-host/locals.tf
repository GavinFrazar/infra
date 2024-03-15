locals {
  account_id = try(data.aws_caller_identity.current[0].account_id, "")
}
