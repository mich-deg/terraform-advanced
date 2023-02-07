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
  name     = "${var.resource_prefix}-RG"
  location = var.location
  tags = {
    source      = "terraform"
    environment = var.envirnoment_map["DEV"]
  }
}

#Create virtual network within the resource group
resource "azurerm_virtual_network" "advanced-vn" {
  name                = "${var.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  address_space       = var.node_address_space

  tags = {
    environment = "dev"
  }

}
# Create a subnets within the virtual network
resource "azurerm_subnet" "advanced-sn" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.advanced-rg.name
  virtual_network_name = azurerm_virtual_network.advanced-vn.name
  address_prefixes     = var.node_address_prefix
}
# Create Network Security Group and Rule
resource "azurerm_network_security_group" "advanced-nsg" {
  name                = "${var.resource_prefix}-nsg"
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

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "advanced-sga" {
  subnet_id                 = azurerm_subnet.advanced-sn.id
  network_security_group_id = azurerm_network_security_group.advanced-nsg.id
}

#Define public IP Address(es)
resource "azurerm_public_ip" "advanced-public-ip" {
  count = var.node_count
  # name                = "${var.resource_prefix}-PublicIP"
  name = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  allocation_method   = "Dynamic"
  tags = {
    environment = "dev"
  }
}
#Define a network interface
resource "azurerm_network_interface" "advanced-nic" {
  count = var.node_count
  # name                = "${var.resource_prefix}-nic"
  name = "${var.resource_prefix}-${format("%02d", count.index)}-nic"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.advanced-sn.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.advanced-IP.id
    public_ip_address_id = element(azurerm_public_ip.advanced-public-ip.*.id, count.index)
  }
  tags = {
    environment = "dev"
  }

}

# Virtual Machine Creation — Linux
resource "azurerm_linux_virtual_machine" "advanced-linux-vm" {
  count = var.node_count
  # name                = "${var.resource_prefix}-vm"
  name = "${var.resource_prefix}-${format("%02d", count.index)}"
  resource_group_name = azurerm_resource_group.advanced-rg.name
  location            = azurerm_resource_group.advanced-rg.location
  size                = "Standard_DS1_v2"
  admin_username      = var.username
  # admin_password        = "P@ssw0rd12!"
  network_interface_ids = [element(azurerm_network_interface.advanced-nic.*.id, count.index)]


  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/terraformkey.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name = "myosdisk-${count.index}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  # disable_password_authentication = false
}

# data "azurerm_public_ip" "ad-ip-data" {
#   name                = azurerm_public_ip.advanced-public-ip.name
#   resource_group_name = azurerm_resource_group.advanced-rg.name
# }

