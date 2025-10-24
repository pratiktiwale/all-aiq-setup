output "id" {
  description = "The ID of the shared App Service Plan."
  # This value exports the ID attribute of the resource created in main.tf
  value       = azurerm_service_plan.main.id 
}

output "name" {
  description = "The name of the shared App Service Plan."
  value       = azurerm_service_plan.main.name
}