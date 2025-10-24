output "function_app_id" {
  description = "The ID of the Function App"
  value       = azurerm_linux_function_app.main.id
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = azurerm_linux_function_app.main.name
}

output "function_app_url" {
  description = "The default URL of the Function App"
  value       = "https://${azurerm_linux_function_app.main.default_hostname}"
}

output "function_app_hostname" {
  description = "The default hostname of the Function App"
  value       = azurerm_linux_function_app.main.default_hostname
}

output "storage_account_name" {
  description = "The name of the storage account used by the Function App"
  value       = azurerm_storage_account.function_storage.name
}

output "service_plan_id" {
  description = "The ID of the Basic service plan"
  value       = azurerm_service_plan.basic.id
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = azurerm_application_insights.function_insights.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights"
  value       = azurerm_application_insights.function_insights.connection_string
  sensitive   = true
}

