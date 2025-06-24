terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"  # Consistent version across all subdirectories; consider centralizing in a shared module
    }
  }
  backend "azurerm" {
    resource_group_name  = var.backend_resource_group_name
    storage_account_name = var.backend_storage_account_name
    container_name       = var.backend_container_name
    key                  = var.backend_key
  }
  # Note: This provider.tf might be unnecessary if backend-support is a one-time setup; consider removing if not managing distinct state
}

provider "azurerm" {
  features {}
}
