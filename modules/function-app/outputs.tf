#-----------------------------------------------------------------------------------------------------------
# Output Attributes of Azure Function App
#-----------------------------------------------------------------------------------------------------------

output "function_app_id" {
  description = "The ID of the Function App"
  value       = azurerm_function_app_flex_consumption.main.id
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = azurerm_function_app_flex_consumption.main.name
}

output "function_app_url" {
  description = "The default URL of the Function App"
  value       = "https://${azurerm_function_app_flex_consumption.main.default_hostname}"
}

output "function_app_hostname" {
  description = "The default hostname of the Function App"
  value       = azurerm_function_app_flex_consumption.main.default_hostname
}

output "storage_account_name" {
  description = "The name of the storage account used by the Function App"
  value       = azurerm_storage_account.function_storage.name
}

output "storage_account_id" {
  description = "The ID of the storage account used by the Function App"
  value       = azurerm_storage_account.function_storage.id
}

output "service_plan_id" {
  description = "The ID of the Flex Consumption service plan"
  value       = azurerm_service_plan.flex_consumption.id
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = var.enable_app_insights ? azurerm_application_insights.function_insights[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights"
  value       = var.enable_app_insights ? azurerm_application_insights.function_insights[0].connection_string : null
  sensitive   = true
}