data "azurerm_user_assigned_identity" "identity-acr" {
  resource_group_name = data.azurerm_resource_group.azure-resource.name
  name                = var.identity_acr_name
}

data "azurerm_storage_account" "public-storage-account" {
  name                = "${var.prefix}${var.storage_account_name_suffix}"
  resource_group_name = data.azurerm_resource_group.azure-resource.name
}

data "azurerm_storage_container" "public-storage-container" {
  name                 = "${var.prefix}${var.storage_container_name_suffix}"
  storage_account_name = data.azurerm_storage_account.public-storage-account.name
}

data "azurerm_network_interface" "network-interface" {
  for_each            = local.services
  name                = each.value.network_interface_name
  resource_group_name = data.azurerm_resource_group.azure-resource.name
}

locals {
  url_static_blob = "https://${data.azurerm_storage_account.public-storage-account.name}.blob.core.windows.net/${data.azurerm_storage_container.public-storage-container.name}"
  services = {
    quotes = {
      name                 = var.vm_quotes_name
      network_interface_name = var.network_interface_quotes_name
      network_interface_id = data.azurerm_network_interface.network-interface["quotes"].id
      provision_script     = "provision-quotes.sh"
      provision_command    = "/home/${var.admin_username}/provision-quotes.sh ${var.prefix}quotes${var.acr_url_default}/${var.prefix}quotes:latest ${data.azurerm_user_assigned_identity.identity-acr.id} ${var.prefix}quotes"
    },
    newsfeed = {
      name                 = var.vm_newsfeed_name
      network_interface_name = var.network_interface_newsfeed_name
      network_interface_id = data.azurerm_network_interface.network-interface["newsfeed"].id
      provision_script     = "provision-newsfeed.sh"
      provision_command    = "/home/${var.admin_username}/provision-newsfeed.sh ${var.prefix}newsfeed${var.acr_url_default}/${var.prefix}newsfeed:latest ${data.azurerm_user_assigned_identity.identity-acr.id} ${var.prefix}newsfeed"
    },
    frontend = {
      name                 = var.vm_frontend_name
      network_interface_name = var.network_interface_frontend_name
      network_interface_id = data.azurerm_network_interface.network-interface["frontend"].id
      provision_script     = "provision-frontend.sh"
      provision_command    = "/home/${var.admin_username}/provision-frontend.sh ${var.prefix}frontend${var.acr_url_default}/${var.prefix}frontend:latest ${data.azurerm_user_assigned_identity.identity-acr.id} ${var.prefix}frontend http://${azurerm_linux_virtual_machine.virtual-machine.quotes.private_ip_address}:8082 http://${azurerm_linux_virtual_machine.virtual-machine.newsfeed.private_ip_address}:8081 ${local.url_static_blob}"
    }
  }
}

resource "azurerm_linux_virtual_machine" "virtual-machine" {
  for_each            = local.services
  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.azure-resource.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    each.value.network_interface_id
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.identity-acr.id]
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("${path.module}/${var.ssh_public_key_path}")
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_type
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  connection {
    host        = self.public_ip_address
    user        = var.admin_username
    type        = "ssh"
    private_key = file("${path.module}/${var.ssh_private_key_path}")
    timeout     = var.connection_timeout
    agent       = var.connection_agent
  }

  provisioner "file" {
    source      = var.provision_docker_script_path
    destination = "/home/${var.admin_username}/provision-docker.sh"
  }

  provisioner "file" {
    source      = lookup({
      "provision-quotes.sh"   = var.provision_quotes_script_path,
      "provision-newsfeed.sh" = var.provision_newsfeed_script_path,
      "provision-frontend.sh" = var.provision_frontend_script_path
    }, each.value.provision_script)
    destination = "/home/${var.admin_username}/${each.value.provision_script}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.admin_username}/provision-docker.sh",
      "/home/${var.admin_username}/provision-docker.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.admin_username}/${each.value.provision_script}",
      each.value.provision_command
    ]
  }
}

output "frontend_url" {
  value = "http://${azurerm_linux_virtual_machine.virtual-machine.frontend.public_ip_address}:8080"
}
