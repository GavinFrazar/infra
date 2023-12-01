output "ec2_databases" {
  description = "The output of the self-hosted db ec2 instance."
  value       = aws_instance.databases
}

output "kms_key" {
  description = "The output of the kms key."
  value       = aws_kms_key.databases
}
