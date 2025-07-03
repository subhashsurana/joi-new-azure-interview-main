locals {
  url_static_blob = "https://${data.azurerm_storage_account.public-storage-account.name}.blob.core.windows.net/${data.azurerm_storage_container.public-storage-container.name}"
  acr_services = {
    quotes   = { name = "${var.prefix}quotes" },
    newsfeed = { name = "${var.prefix}newsfeed" },
    frontend = { name = "${var.prefix}frontend" }
  }
}

# Fetch current Azure subscription to get tenant_id dynamically
data "azurerm_subscription" "current" {}

# Data sources for storage account and container for static blob URL
data "azurerm_storage_account" "public-storage-account" {
  name                = "${var.prefix}${var.storage_account_name_suffix}"
  resource_group_name = var.resource_group_name
}

data "azurerm_storage_container" "public-storage-container" {
  name                 = "${var.prefix}${var.storage_container_name_suffix}"
  storage_account_name = data.azurerm_storage_account.public-storage-account.name
}

# Fetch Azure Container Registry details dynamically for all services
data "azurerm_container_registry" "acr" {
  for_each            = local.acr_services
  name                = each.value.name
  resource_group_name = var.resource_group_name
}


# Azure Container Apps Environment for Joi News Application
resource "azurerm_container_app_environment" "joi_news" {
  name                = "${var.prefix}joi-news-env"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "ca_identity" {
  name                = "ca-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each            = local.acr_services
  scope                = data.azurerm_container_registry.acr[each.key].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.ca_identity.principal_id
  depends_on = [
    azurerm_user_assigned_identity.ca_identity
  ]
}

resource "null_resource" "acr_delay" {
  depends_on = [azurerm_role_assignment.acr_pull]

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

# Azure Key Vault for Secret Management
resource "azurerm_key_vault" "joi_news_vault" {
  name                        = "${var.prefix}joi-news-vault"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_subscription.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

# Key Vault Access Policy for Managed Identities
# Note: This policy should get destroyed before identity
resource "azurerm_key_vault_access_policy" "container_apps_access" {
  key_vault_id = azurerm_key_vault.joi_news_vault.id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = azurerm_user_assigned_identity.ca_identity.principal_id
  secret_permissions = ["Get", "List", "Set", "Delete"]

  depends_on = [azurerm_user_assigned_identity.ca_identity]
}

# Use azurerm_client_config to dynamically fetch the current user's or service principal's object_id
data "azurerm_client_config" "current" {}

# Access policy for the current user or service principal to manage secrets (dynamically fetched during Terraform execution)
# Note: This policy should be destroyed only after dependent resources (like secrets) are removed.
resource "azurerm_key_vault_access_policy" "current_user_access" {
  key_vault_id = azurerm_key_vault.joi_news_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"]
  key_permissions    = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Decrypt", "Encrypt", "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge"]
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"]
}

# Create the newsfeed_service_token secret in Key Vault
# Note: The value is taken from the variable var.newsfeed_service_token, which should be set via environment variable TF_VAR_newsfeed_service_token or in terraform.tfvars file.
# Ensure the environment variable name matches exactly as TF_VAR_newsfeed_service_token (case-sensitive).

resource "azurerm_key_vault_secret" "newsfeed_token" {
  name         = "newsfeed-service-token"
  value        = var.newsfeed_service_token
  key_vault_id = azurerm_key_vault.joi_news_vault.id
  depends_on = [azurerm_key_vault_access_policy.current_user_access]
}

# Define services for Container Apps using locals
locals {
  container_services = {
    quotes = {
      name          = "${var.prefix}quotes"
      container_name = "quotes"
      image         = "${var.prefix}quotes${var.acr_url_default}/${var.prefix}quotes:${var.image_tag_quotes}"
      cpu           = var.cpu_quotes
      memory        = var.memory_quotes
      min_replicas  = var.min_replicas_quotes
      max_replicas  = var.max_replicas_quotes
      external_enabled = var.external_enabled_quotes
      target_port   = var.target_port_quotes
    },
    newsfeed = {
      name          = "${var.prefix}newsfeed"
      container_name = "newsfeed"
      image         = "${var.prefix}newsfeed${var.acr_url_default}/${var.prefix}newsfeed:${var.image_tag_newsfeed}"
      cpu           = var.cpu_newsfeed
      memory        = var.memory_newsfeed
      min_replicas  = var.min_replicas_newsfeed
      max_replicas  = var.max_replicas_newsfeed
      external_enabled = var.external_enabled_newsfeed
      target_port   = var.target_port_newsfeed
    },
    frontend = {
      name          = "${var.prefix}frontend"
      container_name = "frontend"
      image         = "${var.prefix}frontend${var.acr_url_default}/${var.prefix}frontend:${var.image_tag_frontend}"
      cpu           = var.cpu_frontend
      memory        = var.memory_frontend
      min_replicas  = var.min_replicas_frontend
      max_replicas  = var.max_replicas_frontend
      external_enabled = var.external_enabled_frontend
      target_port   = var.target_port_frontend
    }
  }
}

# Container Apps for all services using for_each
resource "azurerm_container_app" "services" {
  for_each                     = local.container_services
  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.joi_news.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = each.value.container_name
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory

      # READINESS PROBE:
      # Ensures the container is ready to handle traffic before routing requests to it.
      # The /ping endpoint is perfect for this.
      readiness_probe {
        transport                 = "HTTP"
        path                    = "/ping"
        port                    = each.value.target_port
        initial_delay           = 10 # Wait 10s before first probe
        interval_seconds          = 10 # Check every 10s
        failure_count_threshold   = 3 # Fail after 3 consecutive failures
        success_count_threshold = 3 # Success after 3 successful probes
      }

      # LIVENESS PROBE:
      # Checks if the container is still running and responsive.
      # If this probe fails, the container will be restarted.
      liveness_probe {
        transport                 = "HTTP"
        path                    = "/ping"
        port                    = each.value.target_port
        initial_delay   = 10 # Wait 10s before first probe
        interval_seconds          = 10 # Check every 10s
        failure_count_threshold   = 3 # Fail after 3 consecutive failures
      }

      dynamic "env" {
        for_each = each.key == "frontend" ? [1] : []
        content {
          name  = "QUOTE_SERVICE_URL"
          value = format("http://%s", local.container_services["quotes"].name)
        }
      }
      dynamic "env" {
        for_each = each.key == "frontend" ? [1] : []
        content {
          name  = "NEWSFEED_SERVICE_URL"
          value = format("http://%s", local.container_services["newsfeed"].name)
        }
      }
      dynamic "env" {
        for_each = each.key == "frontend" ? [1] : []
        content {
          name  = "STATIC_URL"
          value = local.url_static_blob
        }
      }
      dynamic "env" {
        for_each = each.key == "frontend" || each.key == "newsfeed" ? [1] : []
        content {
          name        = "NEWSFEED_SERVICE_TOKEN"
          secret_name = azurerm_key_vault_secret.newsfeed_token.name
        }
      }
      }
    min_replicas = each.value.min_replicas
    max_replicas = each.value.max_replicas
    # AUTO-SCALING CONFIGURATION:
    # This rule will add a new replica when the average number of concurrent HTTP requests over the last 60 seconds is 25 or more.
    http_scale_rule {
        name = "http-scaling-rule"
      
      concurrent_requests = 25
    }
  }

  dynamic "secret" {
    for_each = each.key == "frontend" || each.key == "newsfeed" ? [1] : []
    content {
      name = azurerm_key_vault_secret.newsfeed_token.name
#      value = length(trimspace(var.newsfeed_service_token)) > 0 ? var.newsfeed_service_token : "placeholder-secret-value"
      identity = azurerm_user_assigned_identity.ca_identity.id
      key_vault_secret_id = azurerm_key_vault_secret.newsfeed_token.id
    }
  }

  ingress {
    external_enabled = each.value.external_enabled
    target_port      = each.value.target_port
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
  registry {
    identity = azurerm_user_assigned_identity.ca_identity.id
    server = data.azurerm_container_registry.acr[each.key].login_server
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ca_identity.id]
  }
  depends_on = [
    azurerm_key_vault_access_policy.container_apps_access,
    azurerm_key_vault_secret.newsfeed_token,
    null_resource.acr_delay
  ]
}

# Output the Frontend URL for Access
output "frontend_container_app_url" {
  value = format("https://%s", azurerm_container_app.services["frontend"].ingress[0].fqdn)
}

# Debug output to check if newsfeed_service_token is set
output "newsfeed_service_token_debug" {
  value     = var.newsfeed_service_token
  sensitive = true
}
