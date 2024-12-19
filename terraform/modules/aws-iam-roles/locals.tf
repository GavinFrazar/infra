locals {
  account_id = try(data.aws_caller_identity.this[0].account_id, "")

  db_access_name    = "${var.name_prefix}-db-access"
  db_discovery_name = "${var.name_prefix}-db-discovery"

  clusters = {
    for c in var.clusters :
    c.name => merge(c, {
      tags = merge(var.tags, {
        "teleport.dev/integration" = "teleport-dev-2"
        "teleport.dev/origin"      = "integration_awsoidc"
        "teleport.dev/cluster"     = c.domain
      })
    })
  }
}
