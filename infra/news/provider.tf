# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.50.0"  # Updated to support Azure Container Apps resources
    }
  }

  backend "azurerm" {
    resource_group_name  = "news362151_rg_joi_interview"
    storage_account_name = "news362151sajoiinterview"
    container_name       = "news362151terraformcontainerjoiinterview"
    key                  = "news/terraform.tfstate"
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  # Subscription ID is provided via ARM_SUBSCRIPTION_ID environment variable
}
