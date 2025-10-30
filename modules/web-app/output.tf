#--------------------------------------------------------------------------------------------------
# Output Attributes of Linux Web App
#--------------------------------------------------------------------------------------------------

output "default_hostname" {
  description = "The public hostname (URL) of the deployed Linux Web App."
  value       = azurerm_linux_web_app.main.default_hostname 
}

output "web_app_id" {
  description = "The full resource ID of the Linux Web App."
  value       = azurerm_linux_web_app.main.id
}