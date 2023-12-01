output "self-hosted-databases-ip" {
  value = module.self-hosted-databases[0].ec2_databases[0].public_ip
}

output "my-ip" {
  value = local.my_ip
}
