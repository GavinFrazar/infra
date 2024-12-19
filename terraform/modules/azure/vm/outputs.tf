# Output Public IP
output "public_ip" {
  value = one(azurerm_public_ip.this[*].ip_address)
}
