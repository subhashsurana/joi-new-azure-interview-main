variable "prefix" {
  default = "news362151"
  type    = string
}

variable "location" {
  default = "East US"
  type    = string
}

variable "acr_url_default" {
  default = ".azurecr.io"
  type    = string
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

/*
# Commented out variables not required for Azure Container Apps setup
variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "Admin username for virtual machines"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for VM access"
  type        = string
}

variable "os_disk_caching" {
  description = "Caching type for OS disk"
  type        = string
}

variable "os_disk_storage_type" {
  description = "Storage account type for OS disk"
  type        = string
}

variable "image_publisher" {
  description = "Publisher of the VM image"
  type        = string
}

variable "image_offer" {
  description = "Offer of the VM image"
  type        = string
}

variable "image_sku" {
  description = "SKU of the VM image"
  type        = string
}

variable "image_version" {
  description = "Version of the VM image"
  type        = string
}

variable "connection_timeout" {
  description = "Connection timeout for VM provisioning"
  type        = string
}

variable "connection_agent" {
  description = "Whether to use an agent for SSH connection"
  type        = bool
}
*/

# variable "network_interface_quotes_name" {
#   description = "Name of the network interface for Quotes VM"
#   type        = string
# }

# variable "network_interface_newsfeed_name" {
#   description = "Name of the network interface for Newsfeed VM"
#   type        = string
# }

# variable "network_interface_frontend_name" {
#   description = "Name of the network interface for Frontend VM"
#   type        = string
# }

# variable "vm_quotes_name" {
#   description = "Name of the Quotes virtual machine"
#   type        = string
# }

# variable "vm_newsfeed_name" {
#   description = "Name of the Newsfeed virtual machine"
#   type        = string
# }

# variable "vm_frontend_name" {
#   description = "Name of the Frontend virtual machine"
#   type        = string
# }


variable "storage_account_name_suffix" {
  description = "Suffix for storage account name"
  type        = string
}

variable "storage_container_name_suffix" {
  description = "Suffix for storage container name"
  type        = string
}

# variable "provision_docker_script_path" {
#   description = "Path to the Docker provisioning script"
#   type        = string
# }

# variable "provision_quotes_script_path" {
#   description = "Path to the Quotes provisioning script"
#   type        = string
# }

# variable "provision_newsfeed_script_path" {
#   description = "Path to the Newsfeed provisioning script"
#   type        = string
# }

# variable "provision_frontend_script_path" {
#   description = "Path to the Frontend provisioning script"
#   type        = string
# }

# variable "tenant_id" {
#   description = "Azure Tenant ID for Key Vault configuration"
#   type        = string
# }

variable "identity_acr_name" {
  description = "Name of the user-assigned identity for ACR"
  type        = string
}

variable "newsfeed_service_token" {
  description = "Secret token for Newsfeed service authentication, stored in Key Vault"
  type        = string
  sensitive   = true
}

# Container Apps Configuration for Quotes Service
variable "image_tag_quotes" {
  description = "Docker image tag for Quotes service"
  type        = string
  default     = "latest"
}

variable "cpu_quotes" {
  description = "CPU allocation for Quotes Container App"
  type        = number
  default     = 0.25
}

variable "memory_quotes" {
  description = "Memory allocation for Quotes Container App"
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas_quotes" {
  description = "Minimum number of replicas for Quotes Container App"
  type        = number
  default     = 0
}

variable "max_replicas_quotes" {
  description = "Maximum number of replicas for Quotes Container App"
  type        = number
  default     = 2
}

variable "external_enabled_quotes" {
  description = "Whether external ingress is enabled for Quotes Container App"
  type        = bool
  default     = false
}

variable "target_port_quotes" {
  description = "Target port for Quotes Container App ingress"
  type        = number
  default     = 8082
}

# Container Apps Configuration for Newsfeed Service
variable "image_tag_newsfeed" {
  description = "Docker image tag for Newsfeed service"
  type        = string
  default     = "latest"
}

variable "cpu_newsfeed" {
  description = "CPU allocation for Newsfeed Container App"
  type        = number
  default     = 0.25
}

variable "memory_newsfeed" {
  description = "Memory allocation for Newsfeed Container App"
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas_newsfeed" {
  description = "Minimum number of replicas for Newsfeed Container App"
  type        = number
  default     = 0
}

variable "max_replicas_newsfeed" {
  description = "Maximum number of replicas for Newsfeed Container App"
  type        = number
  default     = 2
}

variable "external_enabled_newsfeed" {
  description = "Whether external ingress is enabled for Newsfeed Container App"
  type        = bool
  default     = false
}

variable "target_port_newsfeed" {
  description = "Target port for Newsfeed Container App ingress"
  type        = number
  default     = 8081
}

# Container Apps Configuration for Frontend Service
variable "image_tag_frontend" {
  description = "Docker image tag for Frontend service"
  type        = string
  default     = "latest"
}

variable "cpu_frontend" {
  description = "CPU allocation for Frontend Container App"
  type        = number
  default     = 0.5
}

variable "memory_frontend" {
  description = "Memory allocation for Frontend Container App"
  type        = string
  default     = "1Gi"
}

variable "min_replicas_frontend" {
  description = "Minimum number of replicas for Frontend Container App"
  type        = number
  default     = 1
}

variable "max_replicas_frontend" {
  description = "Maximum number of replicas for Frontend Container App"
  type        = number
  default     = 3
}

variable "external_enabled_frontend" {
  description = "Whether external ingress is enabled for Frontend Container App"
  type        = bool
  default     = true
}

variable "target_port_frontend" {
  description = "Target port for Frontend Container App ingress"
  type        = number
  default     = 8080
}
