### PROVIDER
terraform {
    required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}
provider "azurerm" {
  # Configuration options
  features {}
}

# Define the Azure Resource Group
resource "azurerm_resource_group" "advanced" {
    name= var.resource_group_name
    location = var.location
#  Flagging Azure resources as managed by terraform using 'source' Tag
    tags = {
      source = "terraform"
    }
}
# Create Network Security Group and Rule
resource "azurerm_network_security_group" "advanced" {
  name = "advanced-nsg"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name

  security_rule {
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "HTTP"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "ICMP"
    priority = 1003
    direction = "Inbound"
    access = "Allow"
    protocol = "Icmp"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}
#Creates Virtual Network
resource "azurerm_virtual_network" "advanced" {
  name = "advanced-vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
}
# Defines a Subnet
resource "azurerm_subnet" "advanced" {
  name = "advanced-subnet"
  resource_group_name = azurerm_resource_group.advanced.name
  virtual_network_name = azurerm_virtual_network.advanced.name
  address_prefixes = ["10.0.1.0/24"]
}
#Define public IP Address
resource "azurerm_public_ip" "advanced" {
  name = "advanced-pIP"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
  allocation_method = "Static"
}
#Define a network interface
resource "azurerm_network_interface" "advanced" {
  name = "advanced-nic"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name

  ip_configuration {
    name = "advanced-config"
    subnet_id = azurerm_subnet.advanced.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "nginxVM" {
  name = "advanced-nginxVM"
  resource_group_name = azurerm_resource_group.advanced.name
  location = azurerm_resource_group.advanced.location
  size = "Standard_DS1_v2"
  admin_username = "adminuser"
  admin_password = "P@ssw0rd12!"
  network_interface_ids = [azurerm_network_interface.advanced.id,]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }

  disable_password_authentication = false
}

