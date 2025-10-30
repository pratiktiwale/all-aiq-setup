#-----------------------------------------------------------------------------------------------------------
# Output Attributes of Azure Blob Storage
#-----------------------------------------------------------------------------------------------------------

output "storage_account_name" {
  description = "The name of the created storage account"
  value       = azurerm_storage_account.main.name
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.main.primary_blob_connection_string
  sensitive   = true
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}
