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

# Identity and Network Interface Names (from main.tf)
identity_acr_name       = "identity-acr"
network_interface_quotes_name = "network-interface-quotes"
network_interface_newsfeed_name = "network-interface-newsfeed"
network_interface_frontend_name = "network-interface-frontend"

# Virtual Machine Names (from main.tf)
vm_quotes_name          = "quotes"
vm_newsfeed_name        = "newsfeed"
vm_frontend_name        = "frontend"

# Storage Configuration (from main.tf)
storage_account_name_suffix = "psa"
storage_container_name_suffix = "psc"

# Provisioning Script Paths
provision_docker_script_path = "./provision-docker.sh"
provision_quotes_script_path = "./provision-quotes.sh"
provision_newsfeed_script_path = "./provision-newsfeed.sh"
provision_frontend_script_path = "./provision-frontend.sh"
