output "workgroup_arn" {
  description = "Redshift serverless workgroup ARN."
  value       = try(aws_redshiftserverless_workgroup.this[0].arn, "")
}

output "namespace_arn" {
  description = "Redshift serverless workgroup ARN."
  value       = try(aws_redshiftserverless_namespace.this[0].arn, "")
}
