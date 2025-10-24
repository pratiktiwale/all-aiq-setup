output "document_intelligence_id" {
  description = "The ID of the Document Intelligence cognitive account"
  value       = azurerm_cognitive_account.document_intelligence.id
}

output "document_intelligence_name" {
  description = "The name of the Document Intelligence service"
  value       = azurerm_cognitive_account.document_intelligence.name
}

output "endpoint" {
  description = "The endpoint URL of the Document Intelligence service"
  value       = azurerm_cognitive_account.document_intelligence.endpoint
}

output "primary_access_key" {
  description = "The primary access key for the Document Intelligence service"
  value       = azurerm_cognitive_account.document_intelligence.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key for the Document Intelligence service"
  value       = azurerm_cognitive_account.document_intelligence.secondary_access_key
  sensitive   = true
}