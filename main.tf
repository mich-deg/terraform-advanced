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
    name="ad-terraform-rg"
    location = "eastus"
#  Flag Azure Resources as Managed by Terraform using 'source' Tag
    tags = {
      source = "terraform"
    }
}
# Create Network Security Group and Rule
resource "azurerm_network_security_group" "advanced" {
  name = "ad-terraform-nsg"
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
  name = "ad-terraform-vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
}
# Defines a Subnet
resource "azurerm_subnet" "advanced" {
  name = "ad-terraform-subnet"
  resource_group_name = azurerm_resource_group.advanced.name
  virtual_network_name = azurerm_virtual_network.advanced.name
  address_prefixes = ["10.0.1.0/24"]
}
#Define public IP Address
resource "azurerm_public_ip" "advanced" {
  name = "ad-terraform-pIP"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
  allocation_method = "Static"
}

#Define a network interface
resource "azurerm_network_interface" "advanced" {
  name = "ad-terraform-nic"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name

  ip_configuration {
    name = "ad-terraform-config"
    subnet_id = azurerm_subnet.advanced.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "advanced" {
  name = "vm-nginx"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
  network_interface_ids = [azurerm_network_interface.advanced.id]
  vm_size = "Standard_DS1_v2"
  
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
