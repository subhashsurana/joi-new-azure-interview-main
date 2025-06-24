variable "prefix" {
  default = "news362151"
  type    = string
}

variable "location" {
  default = "East US"
  type    = string
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "virtual_network_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnet_a_name" {
  description = "Name of the first subnet"
  type        = string
}

variable "subnet_a_address_prefixes" {
  description = "Address prefixes for the first subnet"
  type        = list(string)
}

variable "subnet_b_name" {
  description = "Name of the second subnet"
  type        = string
}

variable "subnet_b_address_prefixes" {
  description = "Address prefixes for the second subnet"
  type        = list(string)
}

variable "route_table_name" {
  description = "Name of the route table"
  type        = string
}

variable "route_name" {
  description = "Name of the route"
  type        = string
}

variable "route_address_prefix" {
  description = "Address prefix for the route"
  type        = string
}

variable "route_next_hop_type" {
  description = "Next hop type for the route"
  type        = string
}

variable "route_table_tag_environment" {
  description = "Environment tag for the route table"
  type        = string
}

variable "quotes_public_ip_sku" {
  description = "SKU for Quotes service public IP"
  type        = string
}

variable "quotes_inbound_port" {
  description = "Inbound port for Quotes service"
  type        = string
}

variable "quotes_rules" {
  description = "Security rules for Quotes service"
  type        = list(map(string))
}

variable "newsfeed_public_ip_sku" {
  description = "SKU for Newsfeed service public IP"
  type        = string
}

variable "newsfeed_inbound_port" {
  description = "Inbound port for Newsfeed service"
  type        = string
}

variable "newsfeed_rules" {
  description = "Security rules for Newsfeed service"
  type        = list(map(string))
}

variable "frontend_public_ip_sku" {
  description = "SKU for Frontend service public IP"
  type        = string
}

variable "frontend_inbound_port" {
  description = "Inbound port for Frontend service"
  type        = string
}

variable "frontend_rules" {
  description = "Security rules for Frontend service"
  type        = list(map(string))
}

variable "identity_acr_name" {
  description = "Name of the user-assigned identity for ACR"
  type        = string
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
}

variable "acr_admin_enabled" {
  description = "Admin enabled flag for Azure Container Registry"
  type        = bool
}

variable "acr_role_name" {
  description = "Role name for ACR access"
  type        = string
}

variable "acr_url_suffix" {
  description = "URL suffix for Azure Container Registry"
  type        = string
}

variable "storage_account_tier" {
  description = "Tier for Azure Storage Account"
  type        = string
}

variable "storage_replication_type" {
  description = "Replication type for Azure Storage Account"
  type        = string
}

variable "storage_container_access_type" {
  description = "Access type for storage container"
  type        = string
}

variable "blob_name" {
  description = "Name of the storage blob"
  type        = string
}

variable "blob_type" {
  description = "Type of the storage blob"
  type        = string
}
