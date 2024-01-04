locals {
  disk_lun   = 10
  backup_dir = "/opt/mc-backups"

  setup_disk_vars = {
    lun       = local.disk_lun
    mount_dir = local.backup_dir
  }
  setup_mcbe_vars = {
    server_name = var.server_name
    level_name  = var.world_name
    backup_dir  = local.backup_dir
  }

  setup_disk_env = join(" ", [for k, v in local.setup_disk_vars : "${k}=\"${v}\""])
  setup_mcbe_env = join(" ", [for k, v in local.setup_mcbe_vars : "${k}=\"${v}\""])
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location
  tags = {
    name = var.name
    kind = "mc-rg"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    name = var.name
    kind = "mc-vnet"
  }
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}-publicip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  tags = {
    name = var.name
    kind = "mc-ip"
  }
}

# Create a network security group and associate it with the virtual machine's network interface
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags = {
    name = var.name
    kind = "mc-nsg"
  }
}

resource "azurerm_network_security_rule" "allow_minecraft" {
  name                        = "allow-minecraft"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "19132-19133"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Create a network interface and associate it with the subnet and public IP address
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    name = var.name
    kind = "mc-nic"
  }
  ip_configuration {
    name                          = "minecraft-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_string" "vm_username" {
  length  = 10
  special = false
  upper   = false
  numeric = false
}

resource "tls_private_key" "vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "server" {
  name                = var.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = random_string.vm_username.result
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  tags = {
    name = var.name
    kind = "mc-server"
  }

  admin_ssh_key {
    username   = random_string.vm_username.result
    public_key = tls_private_key.vm_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "data" {
  name                 = "${var.name}-mc-data"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "4"
  tags = {
    name = var.name
    kind = "mc-data"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  managed_disk_id    = azurerm_managed_disk.data.id
  virtual_machine_id = azurerm_linux_virtual_machine.server.id
  lun                = local.disk_lun
  caching            = "ReadWrite"
  create_option      = "Attach"
}

resource "null_resource" "configure" {
  triggers = {
    id             = azurerm_linux_virtual_machine.server.id
    setup_disk_sh  = filesha256("${path.module}/config/scripts/setup-disk.sh")
    setup_mcbe_sh  = filesha256("${path.module}/config/scripts/setup-mcbe.sh")
    setup_disk_env = local.setup_disk_env
    setup_mcbe_env = local.setup_mcbe_env
  }

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.attachment,
  ]

  connection {
    type        = "ssh"
    user        = random_string.vm_username.result
    host        = azurerm_public_ip.public_ip.ip_address
    private_key = tls_private_key.vm_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/config"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "${local.setup_disk_env} sudo -E sh /tmp/config/scripts/setup-disk.sh",
      "${local.setup_mcbe_env} sudo -E sh /tmp/config/scripts/setup-mcbe.sh",
    ]
  }
}

data "onepassword_vault" "vault" {
  count = var.onepassword_vault == "" ? 0 : 1
  name  = var.onepassword_vault
}

resource "onepassword_item" "generated_secrets" {
  count    = var.onepassword_vault == "" ? 0 : 1
  vault    = one(data.onepassword_vault.vault).uuid
  title    = var.name
  category = "password"
  section {
    label = ""
    field {
      label = "public_ip_address"
      value = azurerm_public_ip.public_ip.ip_address
    }
    field {
      label = "vm_username"
      value = random_string.vm_username.result
    }
    field {
      label = "vm_private_key"
      value = tls_private_key.vm_key.private_key_pem
    }
    field {
      label = "vm_public_key"
      value = tls_private_key.vm_key.public_key_openssh
    }
  }
  tags = [
    "minecraft-server",
  ]
}
