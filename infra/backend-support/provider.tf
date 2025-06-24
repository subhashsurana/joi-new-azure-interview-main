terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"  # Consistent version across all subdirectories; consider centralizing in a shared module
    }
  }
  backend "azurerm" {
    resource_group_name  = "news362151_rg_joi_interview"
    storage_account_name = "news362151sajoiinterview"
    container_name       = "news362151terraformcontainerjoiinterview"
    key                  = "terraform.tfstate"
  }
  # Note: This provider.tf might be unnecessary if backend-support is a one-time setup; consider removing if not managing distinct state
}

provider "azurerm" {
  features {}
}
