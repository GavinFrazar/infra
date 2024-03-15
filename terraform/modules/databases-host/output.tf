output "public_ip" {
  description = "The public IP of the databases ec2 instance host."
  value       = one(aws_instance.this[*].public_ip)
}
