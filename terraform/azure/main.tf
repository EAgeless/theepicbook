data "http" "controller_public_ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  controller_public_ip = "${chomp(data.http.controller_public_ip.response_body)}/32"
}

resource "azurerm_resource_group" "epicbook" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "epicbook" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name
}

resource "azurerm_subnet" "web" {
  name                 = "${var.vm_name}-web-subnet"
  resource_group_name  = azurerm_resource_group.epicbook.name
  virtual_network_name = azurerm_virtual_network.epicbook.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "epicbook" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "epicbook" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  security_rule {
    name                       = "Allow-SSH-From-Controller"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.controller_public_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "epicbook" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.epicbook.location
  resource_group_name = azurerm_resource_group.epicbook.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.epicbook.id
  }
}

resource "azurerm_network_interface_security_group_association" "epicbook" {
  network_interface_id      = azurerm_network_interface.epicbook.id
  network_security_group_id = azurerm_network_security_group.epicbook.id
}

resource "azurerm_linux_virtual_machine" "epicbook" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.epicbook.name
  location                        = azurerm_resource_group.epicbook.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.epicbook.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

resource "azurerm_mysql_flexible_server" "epicbook" {
  name                   = var.mysql_server_name
  resource_group_name    = azurerm_resource_group.epicbook.name
  location               = azurerm_resource_group.epicbook.location
  administrator_login    = var.mysql_admin_username
  administrator_password = var.mysql_admin_password

  sku_name = "B_Standard_B1ms"
  version  = "8.0.21"
  storage {
    size_gb = 20
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
}

resource "azurerm_mysql_flexible_database" "epicbook" {
  name                = var.db_name
  resource_group_name = azurerm_resource_group.epicbook.name
  server_name         = azurerm_mysql_flexible_server.epicbook.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_controller" {
  name                = "allow-controller-public-ip"
  resource_group_name = azurerm_resource_group.epicbook.name
  server_name         = azurerm_mysql_flexible_server.epicbook.name
  start_ip_address    = trimsuffix(local.controller_public_ip, "/32")
  end_ip_address      = trimsuffix(local.controller_public_ip, "/32")
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "allow-azure-services"
  resource_group_name = azurerm_resource_group.epicbook.name
  server_name         = azurerm_mysql_flexible_server.epicbook.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
