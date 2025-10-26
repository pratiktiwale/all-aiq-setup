# modules/azure-ai-foundry/outputs.tf

# Azure AI Foundry Outputs
output "ai_foundry_id" {
  description = "The ID of the Azure AI Foundry service"
  value       = azurerm_cognitive_account.ai_foundry.id
}

output "ai_foundry_name" {
  description = "The name of the Azure AI Foundry service"
  value       = azurerm_cognitive_account.ai_foundry.name
}

output "ai_foundry_endpoint" {
  description = "The endpoint URL of the Azure AI Foundry service"
  value       = azurerm_cognitive_account.ai_foundry.endpoint
}

output "ai_foundry_primary_key" {
  description = "The primary access key for the Azure AI Foundry service"
  value       = azurerm_cognitive_account.ai_foundry.primary_access_key
  sensitive   = true
}

output "ai_foundry_secondary_key" {
  description = "The secondary access key for the Azure AI Foundry service"
  value       = azurerm_cognitive_account.ai_foundry.secondary_access_key
  sensitive   = true
}



# AI Foundry Portal URL
output "ai_foundry_portal_url" {
  description = "The Azure AI Foundry portal URL"
  value       = "https://ai.azure.com/"
}

#----------------------------------------------------------------------------------------------------------------
# Deployment Outputs
#----------------------------------------------------------------------------------------------------------------

# GPT-4o Deployment Outputs
output "gpt4_deployment_id" {
  description = "The ID of the GPT-4o deployment"
  value       = azurerm_cognitive_deployment.gpt4.id
}

output "gpt4_deployment_name" {
  description = "The name of the GPT-4o deployment"
  value       = azurerm_cognitive_deployment.gpt4.name
}

# Embedding Deployment Outputs
output "embedding_deployment_id" {
  description = "The ID of the text-embedding-ada-002 deployment"
  value       = azurerm_cognitive_deployment.embedding.id
}

output "embedding_deployment_name" {
  description = "The name of the text-embedding-ada-002 deployment"
  value       = azurerm_cognitive_deployment.embedding.name
}