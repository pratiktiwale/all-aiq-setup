output "search_service_id" {
  value = azurerm_search_service.this.id
}

output "search_service_name" {
  description = "The name of the Azure AI Search service"
  value       = azurerm_search_service.this.name
}

output "search_service_url" {
  description = "The URL of the Azure AI Search service"
  value       = "https://${azurerm_search_service.this.name}.search.windows.net"
}

output "search_service_primary_key" {
  description = "The primary admin key for the Azure AI Search service"
  value       = azurerm_search_service.this.primary_key
  sensitive   = true
}

output "search_service_query_keys" {
  description = "The query keys for the Azure AI Search service"
  value       = azurerm_search_service.this.query_keys
  sensitive   = true
}

output "index_name" {
  description = "The name of the created search index"
  value       = var.create_index ? var.index_name : null
}