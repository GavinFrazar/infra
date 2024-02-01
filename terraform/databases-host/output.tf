output "ec2_databases" {
  description = "The output of the self-hosted db ec2 instance."
  value       = aws_instance.db-host
}
