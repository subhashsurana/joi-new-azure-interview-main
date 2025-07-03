# Backend Configuration (from provider.tf)
# backend_resource_group_name  = "news362151_rg_joi_interview"
# backend_storage_account_name = "news362151sajoiinterview"
# backend_container_name       = "news362151terraformcontainerjoiinterview"
# backend_key                  = "news/terraform.tfstate"

# Resource Group Configuration (from provider.tf)
resource_group_name     = "news362151_rg_joi_interview"

# General Variables (from variables.tf)
prefix                  = "news362151"
location                = "East US"
acr_url_default         = ".azurecr.io"

/*
# Commented out variables not required for Azure Container Apps setup
# Virtual Machine Configuration (from main.tf)
vm_size                 = "Standard_F2"
admin_username          = "adminuser"
ssh_public_key_path     = "../id_rsa.pub"
ssh_private_key_path    = "../id_rsa"
os_disk_caching         = "ReadWrite"
os_disk_storage_type    = "Standard_LRS"
image_publisher         = "Canonical"
image_offer             = "UbuntuServer"
image_sku               = "18.04-LTS"
image_version           = "latest"
connection_timeout      = "1m"
connection_agent        = true

# Network Interface Names (from main.tf)
network_interface_quotes_name = "network-interface-quotes"
network_interface_newsfeed_name = "network-interface-newsfeed"
network_interface_frontend_name = "network-interface-frontend"

# Virtual Machine Names (from main.tf)
vm_quotes_name          = "quotes"
vm_newsfeed_name        = "newsfeed"
vm_frontend_name        = "frontend"
*/

# Identity (retained for ACR access in Container Apps)
identity_acr_name       = "identity-acr"

# Storage Configuration (from main.tf)
storage_account_name_suffix = "psa"
storage_container_name_suffix = "psc"

# Provisioning Script Paths
# provision_docker_script_path = "./provision-docker.sh"
# provision_quotes_script_path = "./provision-quotes.sh"
# provision_newsfeed_script_path = "./provision-newsfeed.sh"
# provision_frontend_script_path = "./provision-frontend.sh"

# Key Vault Configuration (for Container Apps)
# tenant_id is now dynamically fetched from the current Azure subscription using a data source in Terraform.
# newsfeed_service_token is not hardcoded; it should be pre-stored in Key Vault as "newsfeed-service-token"
# or passed securely during Terraform apply using an environment variable:
# TF_VAR_newsfeed_service_token=<your-token> terraform apply

# Container Apps Configuration for Quotes Service
image_tag_quotes        = "latest"
cpu_quotes              = 0.25
memory_quotes           = "0.5Gi"
min_replicas_quotes     = 1
max_replicas_quotes     = 2
external_enabled_quotes = false
target_port_quotes      = 8082

# Container Apps Configuration for Newsfeed Service
image_tag_newsfeed      = "latest"
cpu_newsfeed            = 0.25
memory_newsfeed         = "0.5Gi"
min_replicas_newsfeed   = 1
max_replicas_newsfeed   = 2
external_enabled_newsfeed = false
target_port_newsfeed    = 8081

# Container Apps Configuration for Frontend Service
image_tag_frontend      = "latest"
cpu_frontend            = 0.5
memory_frontend         = "1Gi"
min_replicas_frontend   = 1
max_replicas_frontend   = 3
external_enabled_frontend = true
target_port_frontend    = 8080
