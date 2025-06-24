# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
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
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "azure-resource" {
  name = var.resource_group_name
}
