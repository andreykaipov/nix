output "vm" {
  value = azurerm_linux_virtual_machine.server
}

output "secrets" {
  sensitive = true
  value = {
    public_ip_address = azurerm_public_ip.public_ip.ip_address
    username          = random_string.vm_username.result
    vm_private_key    = tls_private_key.vm_key.private_key_pem
    vm_public_key     = tls_private_key.vm_key.public_key_openssh
  }
}
