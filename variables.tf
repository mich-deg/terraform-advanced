# variable "resource_group_name" {
#   type        = string
#   description = "Resource Group name"
#   default     = "ad-rg"
# }

variable "resource_prefix" {
  type = string
}
variable "location" {
  type        = string
  description = "The location for deployment"
  default     = "East Us"
}


variable "node_address_space" {
  default = ["10.0.0.0/16"]
}

#variable for network range
variable "node_address_prefix" {
  default = ["10.0.1.0/24"]
}

variable "node_count" {
  type = number
}
variable "envirnoment_map" {
  type = map(string)
  default = {
    DEV = "dev",
    STAGE = "stage",
    PROD = "prod"
  }
}

variable "username" {
  type = string
  sensitive = true
  default = "adminuser"
}

variable "vm" {
  type = list(string)
  description = "List of virtual machines"
}
