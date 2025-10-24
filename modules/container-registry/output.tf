# modules/acr/outputs.tf

output "login_server" {
  description = "The login server URL (e.g., myregistry.azurecr.io)."
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "The admin username for ACR."
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "The primary admin password for ACR."
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "backend_repository_name" {
  description = "The name of the repository for the backend image."
  value       = var.backend_repo_name
}

output "frontend_repository_name" {
  description = "The name of the repository for the frontend image."
  value       = var.frontend_repo_name
}

output "registry_id" {
  description = "The ID of the container registry"
  value       = azurerm_container_registry.main.id
}