variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
  default     = "ad-rg"
}

variable "location" {
  type        = string
  description = "The location for deployment"
  default     = "East Us"
}

variable "envirnoment_map" {
  type = map(string)
  default = {
    DEV = "dev",
    STAGE = "stage",
    PROD = "prod"
  }
}
