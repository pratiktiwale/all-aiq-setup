#----------------------------------------------------------------------------------------------------------------
# Root module outputs for easy access to resource information
#----------------------------------------------------------------------------------------------------------------

# Managed Identity outputs

output "managed_identity_client_id" {
  description = "Client ID of the managed identity"
  value       = module.managed_identity.managed_identity_client_id
}
output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = module.managed_identity.managed_identity_principal_id
}
output "managed_identity_name" {
  description = "Name of the managed identity"
  value       = module.managed_identity.managed_identity_name
}
