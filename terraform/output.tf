# Terraform output for public IP address
output "public_ip_address" {
  description = "The public IP address"
  value = azurerm_public_ip.public_ip.ip_address
}