output "endpoint" {
  description = "Redshift cluster endpoint."
  value       = try(aws_redshift_cluster.this[0].endpoint, "")
}
