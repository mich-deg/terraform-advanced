### PROVIDER
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}
provider "azurerm" {
  # Configuration options
  features {}
}
# Define the Azure Resource Group
resource "azurerm_resource_group" "advanced-rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    source      = "terraform"
    environment = "dev"
  }
}

#Creates Virtual Network
resource "azurerm_virtual_network" "advanced-vn" {
  name                = "advanced-vnet"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "dev"
  }

}
# Defines a Subnet
resource "azurerm_subnet" "advanced-sn" {
  name                 = "advanced-subnet"
  resource_group_name  = azurerm_resource_group.advanced-rg.name
  virtual_network_name = azurerm_virtual_network.advanced-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create Network Security Group and Rule
resource "azurerm_network_security_group" "advanced-nsg" {
  name                = "advanced-nsg"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  tags = {
    environment = "dev"
  }
}
resource "azurerm_network_security_rule" "advanced-SSH-rule" {
  name                        = "SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.advanced-rg.name
  network_security_group_name = azurerm_network_security_group.advanced-nsg.name
}
resource "azurerm_network_security_rule" "advanced-HTTP-rule" {
  name                        = "HTTP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.advanced-rg.name
  network_security_group_name = azurerm_network_security_group.advanced-nsg.name
}
resource "azurerm_network_security_rule" "advanced-ICMP-rule" {
  name                        = "ICMP"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.advanced-rg.name
  network_security_group_name = azurerm_network_security_group.advanced-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "advanced-sga" {
  subnet_id                 = azurerm_subnet.advanced-sn.id
  network_security_group_id = azurerm_network_security_group.advanced-nsg.id
}

#Define public IP Address
resource "azurerm_public_ip" "advanced-IP" {
  name                = "advanced-IP"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  allocation_method   = "Dynamic"
  tags = {
    environment = "dev"
  }
}
#Define a network interface
resource "azurerm_network_interface" "advanced-nic" {
  name                = "advanced-nic"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.advanced-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.advanced-IP.id
  }
  tags = {
    environment = "dev"
  }

}

resource "azurerm_linux_virtual_machine" "nginxVM" {
  name                = "advanced-nginxVM"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  # admin_password        = "P@ssw0rd12!"
  network_interface_ids = [azurerm_network_interface.advanced-nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/terraformkey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  # disable_password_authentication = false
}

data "azurerm_public_ip" "ad-ip-data" {
  name                = azurerm_public_ip.advanced-IP.name
  resource_group_name = azurerm_resource_group.advanced-rg.name
}

