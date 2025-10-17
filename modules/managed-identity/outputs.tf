output "managed_identity_id" {
  description = "The ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.id
}

output "managed_identity_name" {
  description = "The name of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.name
}

output "managed_identity_principal_id" {
  description = "The principal ID (object ID) of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.principal_id
}

output "managed_identity_client_id" {
  description = "The client ID (application ID) of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.client_id
}

output "managed_identity_tenant_id" {
  description = "The tenant ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.main.tenant_id
}