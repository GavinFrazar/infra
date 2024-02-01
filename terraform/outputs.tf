output "databases-host-ip" {
  value = local.enabled.databases-host ? module.databases-host[0].ec2_databases.public_ip : null
}

output "my-ip" {
  value = local.my_ip
}
