output "public_ip" {
  description = "Public IP address of the EpicBook virtual machine."
  value       = azurerm_public_ip.epicbook.ip_address
}

output "admin_user" {
  description = "Administrator username for the EpicBook virtual machine."
  value       = var.admin_username
}

output "db_host" {
  description = "Fully qualified domain name of the Azure MySQL Flexible Server."
  value       = azurerm_mysql_flexible_server.epicbook.fqdn
}

output "db_name" {
  description = "Name of the EpicBook MySQL database."
  value       = azurerm_mysql_flexible_database.epicbook.name
}
