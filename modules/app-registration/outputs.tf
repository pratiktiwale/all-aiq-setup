output "application_id" {
  description = "The application ID (client ID) of the app registration"
  value       = azuread_application.main.client_id
}

output "object_id" {
  description = "The object ID of the app registration"
  value       = azuread_application.main.object_id
}

output "display_name" {
  description = "The display name of the app registration"
  value       = azuread_application.main.display_name
}

output "service_principal_id" {
  description = "The object ID of the service principal (Enterprise App)"
  value       = azuread_service_principal.main.object_id
}

output "client_secret_value" {
  description = "The value of the client secret"
  value       = azuread_application_password.main.value
  sensitive   = true
}

output "application_id_uri" {
  description = "The Application ID URI (api://{client-id})"
  value       = "api://${azuread_application.main.client_id}"
}