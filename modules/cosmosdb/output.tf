# modules/cosmosdb/outputs.tf

output "primary_connection_string" {
  description = "The primary connection string for the Cosmos DB account."
  # CRITICAL: Mark as sensitive so it is not displayed in the console output
   value       = azurerm_cosmosdb_account.main.primary_sql_connection_string 
  sensitive   = true 
}

output "cosmos_account_name" {
  description = "The name of the created Cosmos DB account."
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmosdb_account_id" {
  description = "The ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.id
}

output "endpoint" {
  description = "The endpoint URL for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "primary_key" {
  description = "The primary access key for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "database_name" {
  description = "The name of the created Cosmos DB database"
  value       = azurerm_cosmosdb_sql_database.main.name
}