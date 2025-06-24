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
  
}

resource "azurerm_management_lock" "acr_mgmt_lock" {
  name               = "acr-mgmt-lock"
  resource_group_name = var.azurerm_resource_group_name
  resource_type      = "Microsoft.ContainerRegistry/registries"
  resource_name      = azurerm_container_registry.registry[each.key].name
  resource_id        = azurerm_container_registry.registry[each.key].id
  lock_level         = "CanNotDelete"  # or "ReadOnly"
  depends_on = [azurerm_container_registry.registry]
}


resource "random_uuid" "acrpull_id" {
  for_each = local.registry_services
  keepers = {
    acr_id = azurerm_container_registry.registry[each.key].id
    sp_id  = azurerm_user_assigned_identity.identity-acr.principal_id
    role   = "AcrPull"
  }
}

data "azurerm_role_definition" "acrpull" {
  name = var.acr_role_name
}

resource "azurerm_role_assignment" "acr_acrpull" {
  for_each           = local.registry_services
  name               = random_uuid.acrpull_id[each.key].result
  scope              = azurerm_container_registry.registry[each.key].id
  role_definition_id = data.azurerm_role_definition.acrpull.id
  principal_id       = azurerm_user_assigned_identity.identity-acr.principal_id
}

locals {
  acr_url = var.acr_url_suffix
}

resource "local_file" "acr" {
  filename = "${path.module}/../acr-url.txt"
  content  = local.acr_url
}
