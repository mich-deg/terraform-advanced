output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.nginxVM.name}: ${data.azurerm_public_ip.ad-ip-data.ip_address}"
}