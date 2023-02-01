variable "rg_name" {
    type = string
    description = "Resource Group name"
    default = "advanced-rg"
}

variable "rg_location" {
    type = string
    description = "The location for deployment"
    default = "East US"
}

variable "nsg_name" {
  type = string
  description = "Network Security Group name"
  default = "advanced-nsg"
}

variable "vn_name" {
  type = string
  description = "Virtual Network name"
  default = "advanced-vnet"
}

variable "subnet_name" {
  type = string
  description = "Subnet name"
  default = "advanced-subnet"
}

variable "nic_name" {
  type = string
  description = "Network Interface name"
  default = "advanced-nic"
}

variable "address_space" {
  type = string
  default = "10.0.0.0/16"
}