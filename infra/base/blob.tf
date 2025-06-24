
resource "azurerm_storage_account" "public-storage-account" {
  name                     = "${var.prefix}psa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  min_tls_version         = "TLS1_2"
  
}

resource "azurerm_storage_container" "public-storage-container" {
  name                  = "${var.prefix}psc"
  storage_account_name  = azurerm_storage_account.public-storage-account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob-static" {
  name                   = var.blob_name
  storage_account_name   = azurerm_storage_account.public-storage-account.name
  storage_container_name = azurerm_storage_container.public-storage-container.name
  type                   = var.blob_type
}

output "url_blob" {
  value = "https://${azurerm_storage_account.public-storage-account.name}.blob.core.windows.net/${azurerm_storage_container.public-storage-container.name}/static/"
}
