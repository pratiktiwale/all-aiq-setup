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

output "search_service_principal_id" {
  description = "The principal ID of the search service's system-assigned managed identity"
  value       = azurerm_search_service.this.identity[0].principal_id
}

output "index_name" {
  description = "The name of the created search index"
  value       = var.create_index ? var.index_name : null
}