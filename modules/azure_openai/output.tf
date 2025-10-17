output "cognitive_account_id" {
  value = azurerm_cognitive_account.openai.id
}

output "gpt_deployment_id" {
  value = azurerm_cognitive_deployment.gpt.id
}

output "embedding_deployment_id" {
  value = azurerm_cognitive_deployment.embedding.id
}

output "endpoint" {
  description = "The endpoint URL of the Azure OpenAI service"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "primary_access_key" {
  description = "The primary access key for the Azure OpenAI service"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

output "embedding_deployment_name" {
  description = "The name of the embedding deployment"
  value       = azurerm_cognitive_deployment.embedding.name
}

output "gpt_deployment_name" {
  description = "The name of the GPT deployment"
  value       = azurerm_cognitive_deployment.gpt.name
}
