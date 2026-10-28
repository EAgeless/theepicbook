variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westus2"
}

variable "vm_name" {
  description = "Name of the EpicBook virtual machine."
  type        = string
  default     = "vm-epicbook-prod"
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_F1ams_v7"
}

variable "admin_username" {
  description = "Administrator username for the Ubuntu VM."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to the controller public SSH key."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "mysql_server_name" {
  description = "Globally unique name for the Azure MySQL Flexible Server."
  type        = string
}

variable "mysql_admin_username" {
  description = "Administrator username for Azure MySQL Flexible Server."
  type        = string
  default     = "mysqladmin"
}

variable "mysql_admin_password" {
  description = "Administrator password for Azure MySQL Flexible Server."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Name of the EpicBook database."
  type        = string
  default     = "epicbookdb"
}
