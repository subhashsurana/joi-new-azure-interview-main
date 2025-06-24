# Backend Configuration (from provider.tf)
# backend_resource_group_name  = "news362151_rg_joi_interview"
# backend_storage_account_name = "news362151sajoiinterview"
# backend_container_name       = "news362151terraformcontainerjoiinterview"
# backend_key                  = "base/terraform.tfstate"

# Provider Configuration (from provider.tf)
resource_group_name     = "news362151_rg_joi_interview"

# General Variables (from variables.tf)
prefix                  = "news362151"
location                = "East US"

# Network Configuration (from avn.tf)
virtual_network_name    = "virtual-network"
virtual_network_address_space = ["10.5.0.0/16"]
subnet_a_name           = "public_subnet_a"
subnet_a_address_prefixes = ["10.5.0.0/24"]
subnet_b_name           = "public_subnet_b"
subnet_b_address_prefixes = ["10.5.1.0/24"]
route_table_name        = "route-table"
route_name              = "route"
route_address_prefix    = "0.0.0.0/0"
route_next_hop_type     = "Internet"
route_table_tag_environment = "Production"

# Service Configurations for Network (from avn.tf)
quotes_public_ip_sku    = "Standard"
quotes_inbound_port     = "8082"
quotes_rules = [
  { type = "outbound", priority = 1000, direction = "Outbound", port_range = "*", dest_prefix = "*" },
  { type = "ssh", priority = 1003, direction = "Inbound", port_range = "22", dest_prefix = "VirtualNetwork" },
  { type = "port", priority = 1006, direction = "Inbound", port_range = "8082", dest_prefix = "*" }
]
newsfeed_public_ip_sku  = "Standard"
newsfeed_inbound_port   = "8081"
newsfeed_rules = [
  { type = "outbound", priority = 1001, direction = "Outbound", port_range = "*", dest_prefix = "*" },
  { type = "ssh", priority = 1004, direction = "Inbound", port_range = "22", dest_prefix = "VirtualNetwork" },
  { type = "port", priority = 1007, direction = "Inbound", port_range = "8081", dest_prefix = "*" }
]
frontend_public_ip_sku  = "Standard"
frontend_inbound_port   = "8080"
frontend_rules = [
  { type = "outbound", priority = 1002, direction = "Outbound", port_range = "*", dest_prefix = "*" },
  { type = "ssh", priority = 1005, direction = "Inbound", port_range = "22", dest_prefix = "VirtualNetwork" },
  { type = "port", priority = 1008, direction = "Inbound", port_range = "8080", dest_prefix = "*" }
]

# Container Registry Configuration (from acr.tf)
identity_acr_name       = "identity-acr"
acr_sku                 = "Basic"
acr_admin_enabled       = false
acr_role_name           = "AcrPull"
acr_url_suffix          = ".azurecr.io"

# Storage Configuration (from blob.tf)
storage_account_tier    = "Standard"
storage_replication_type = "LRS"
storage_container_access_type = "blob"
blob_name               = "static"
blob_type               = "Block"
