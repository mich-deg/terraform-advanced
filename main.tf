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

resource "azurerm_resource_group" "advanced" {
    name="ad-terraform-rg"
    location = "eastus"
}

#Creates Virtual Network
resource "azurerm_virtual_network" "advanced" {
  name = "ad-terraform-vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
}

resource "azurerm_subnet" "advanced" {
  name = "ad-terraform-subnet"
  resource_group_name = azurerm_resource_group.advanced.name
  virtual_network_name = azurerm_virtual_network.advanced.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "advanced" {
  name = "ad-terraform-nsg"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
}

resource "azurerm_network_security_rule" "advanced" {
  name = "ad-terraform-nsr"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "80"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.advanced.name
  network_security_group_name = azurerm_network_security_group.advanced.name
}

resource "azurerm_public_ip" "advanced_nginx" {
  name = "nginx-public-ip"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
  allocation_method = "Static"
}

resource "azurerm_network_interface" "advanced_nginx" {
  name = "ad-nginx-nic"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name

  ip_configuration {
    name = "ad-nginx-config"
    subnet_id = azurerm_subnet.advanced.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.advanced_nginx.id
  }
}

resource "azurerm_virtual_machine" "advanced_nginx" {
  name = "ad-nginx"
  location = azurerm_resource_group.advanced.location
  resource_group_name = azurerm_resource_group.advanced.name
  network_interface_ids = [azurerm_network_interface.advanced_nginx.id]
  vm_size = "Standard_DS1_v2"

  delete_os_disk_on_termination = true

  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
}
# resource "azurerm_firewall" "advanced" {
#   name= "test-firewall"
#   location = azurerm_resource_group.advanced.location
#   resource_group_name = azurerm_resource_group.advanced.name
#   sku_name = "AZFW_VNet"
#   sku_tier = "Standard"

#   ip_configuration {
#     name = "configration"
#     subnet_id = azurerm_subnet.internal.id
#     public_ip_address_id = azurerm_public_ip.advanced.id
#   }
# }

# resource "azurerm_network_interface" "advanced" {
#   name = "ad-terraform-nic"
#   location = azurerm_resource_group.advanced.location
#   resource_group_name = azurerm_resource_group.advanced.name

#   ip_configuration {
#     name = "advancedconfig"
#     subnet_id = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_virtual_machine" "nginx_instance" {
#   name = "nginx-vm"
#   location = azurerm_resource_group.advanced.location
#   resource_group_name = azurerm_resource_group.advanced.name
#   network_interface_ids = [ azurerm_network_interface.advanced.id ]
#   vm_size = "Standard_DS1_v2"

#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   # delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer = "UbuntuServer"
#     sku = "18.04-LTS"
#     version = "latest"
#   }

#   storage_os_disk {
#     name = "myosdisk1"
#     caching = "ReadWrite"
#     create_option = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "hostname"
#     admin_username = "testadmin"
#     admin_password = "Password1234!"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
#   tags = {
#     environment = "web"
#   }
# }

# resource "azurerm_virtual_machine" "web1" {
#   name = "web1"
#   location = azurerm_resource_group.advanced.location
#   resource_group_name = azurerm_resource_group.advanced.name
#   network_interface_ids = [ azurerm_network_interface.advanced.id ]
#   vm_size = "Standard_DS1_v2"

#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   # delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer = "UbuntuServer"
#     sku = "18.04-LTS"
#     version = "latest"
#   }

#   storage_os_disk {
#     name = "myosdisk1"
#     caching = "ReadWrite"
#     create_option = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "hostname"
#     admin_username = "testadmin"
#     admin_password = "Password1234!"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
  
# }

# resource "azurerm_virtual_machine" "web2" {
#   name = "web2"
#   location = azurerm_resource_group.advanced.location
#   resource_group_name = azurerm_resource_group.advanced.name
#   network_interface_ids = [ azurerm_network_interface.advanced.id ]
#   vm_size = "Standard_DS1_v2"

#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   # delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer = "UbuntuServer"
#     sku = "18.04-LTS"
#     version = "latest"
#   }

#   storage_os_disk {
#     name = "myosdisk1"
#     caching = "ReadWrite"
#     create_option = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "hostname"
#     admin_username = "testadmin"
#     admin_password = "Password1234!"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
  
# }

# resource "azurerm_virtual_machine" "web3" {
#   name = "web3"
#   location = azurerm_resource_group.advanced.location
#   resource_group_name = azurerm_resource_group.advanced.name
#   network_interface_ids = [ azurerm_network_interface.advanced.id ]
#   vm_size = "Standard_DS1_v2"

#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   # delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer = "UbuntuServer"
#     sku = "18.04-LTS"
#     version = "latest"
#   }

#   storage_os_disk {
#     name = "myosdisk1"
#     caching = "ReadWrite"
#     create_option = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "hostname"
#     admin_username = "testadmin"
#     admin_password = "Password1234!"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
  
# }

# resource "azurerm_virtual_machine" "mysqldb" {
#   name = "mysqldb"
#   location = azurerm_resource_group.advanced.location
#   resource_group_name = azurerm_resource_group.advanced.name
#   network_interface_ids = [ azurerm_network_interface.advanced.id ]
#   vm_size = "Standard_DS1_v2"

#   # Uncomment this line to delete the OS disk automatically when deleting the VM
#   delete_os_disk_on_termination = true

#   # Uncomment this line to delete the data disks automatically when deleting the VM
#   # delete_data_disks_on_termination = true

#   storage_image_reference {
#     publisher = "Canonical"
#     offer = "UbuntuServer"
#     sku = "18.04-LTS"
#     version = "latest"
#   }

#   storage_os_disk {
#     name = "myosdisk1"
#     caching = "ReadWrite"
#     create_option = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   os_profile {
#     computer_name  = "hostname"
#     admin_username = "testadmin"
#     admin_password = "Password1234!"
#   }
#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
  
# }


