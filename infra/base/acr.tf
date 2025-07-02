resource "azurerm_user_assigned_identity" "identity-acr" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.identity_acr_name
}

# Define services for container registries
locals {
  registry_services = {
    quotes   = { name = "${var.prefix}quotes" },
    newsfeed = { name = "${var.prefix}newsfeed" },
    frontend = { name = "${var.prefix}frontend" }
  }
}

resource "azurerm_container_registry" "registry" {
  for_each            = local.registry_services
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity-acr.id]
  }
  depends_on = [azurerm_user_assigned_identity.identity-acr]  
}

data "azurerm_role_definition" "acrpull" {
  name = var.acr_role_name
}

resource "azurerm_role_assignment" "acr_acrpull" {
  for_each           = local.registry_services
  scope              = azurerm_container_registry.registry[each.key].id
  role_definition_name = data.azurerm_role_definition.acrpull.name
  principal_id       = azurerm_user_assigned_identity.identity-acr.principal_id
}

locals {
  acr_url = var.acr_url_suffix
}

resource "local_file" "acr" {
  filename = "${path.module}/../acr-url.txt"
  content  = local.acr_url
}
