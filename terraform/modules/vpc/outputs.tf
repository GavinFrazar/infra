output "id" {
  value = module.this.vpc_id
}

output "database_subnet_group_name" {
  value = module.this.database_subnet_group_name
}

output "private_subnets" {
  value = module.this.private_subnets
}

output "public_subnets" {
  value = module.this.public_subnets
}
