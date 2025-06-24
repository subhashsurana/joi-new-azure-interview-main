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

variable "identity_acr_name" {
  description = "Name of the user-assigned identity for ACR"
  type        = string
}

variable "network_interface_quotes_name" {
  description = "Name of the network interface for Quotes VM"
  type        = string
}

variable "network_interface_newsfeed_name" {
  description = "Name of the network interface for Newsfeed VM"
  type        = string
}

variable "network_interface_frontend_name" {
  description = "Name of the network interface for Frontend VM"
  type        = string
}

variable "vm_quotes_name" {
  description = "Name of the Quotes virtual machine"
  type        = string
}

variable "vm_newsfeed_name" {
  description = "Name of the Newsfeed virtual machine"
  type        = string
}

variable "vm_frontend_name" {
  description = "Name of the Frontend virtual machine"
  type        = string
}

variable "storage_account_name_suffix" {
  description = "Suffix for storage account name"
  type        = string
}

variable "storage_container_name_suffix" {
  description = "Suffix for storage container name"
  type        = string
}

variable "provision_docker_script_path" {
  description = "Path to the Docker provisioning script"
  type        = string
}

variable "provision_quotes_script_path" {
  description = "Path to the Quotes provisioning script"
  type        = string
}

variable "provision_newsfeed_script_path" {
  description = "Path to the Newsfeed provisioning script"
  type        = string
}

variable "provision_frontend_script_path" {
  description = "Path to the Frontend provisioning script"
  type        = string
}
