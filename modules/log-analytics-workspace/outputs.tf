
#----------------------------------------------------------------------------------------------------------------
# Log Analytics Workspace Outputs
#----------------------------------------------------------------------------------------------------------------

output "workspace_id" {
  description = "The Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "workspace_name" {
  description = "The Log Analytics Workspace name"
  value       = azurerm_log_analytics_workspace.main.name
}

output "primary_shared_key" {
  description = "The primary shared key for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "The secondary shared key for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.secondary_shared_key
  sensitive   = true
}

output "workspace_location" {
  description = "The location of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.location
}

output "workspace_resource_group_name" {
  description = "The resource group name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.resource_group_name
}

output "workspace_sku" {
  description = "The SKU of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.sku
}

output "workspace_retention_in_days" {
  description = "The retention period in days for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.retention_in_days
}

output "workspace_daily_quota_gb" {
  description = "The daily quota in GB for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.daily_quota_gb
}

#----------------------------------------------------------------------------------------------------------------
# Connection Information for Application Insights
#----------------------------------------------------------------------------------------------------------------

output "connection_info" {
  description = "Connection information for integrating with Application Insights"
  value = {
    workspace_id  = azurerm_log_analytics_workspace.main.workspace_id
    workspace_key = azurerm_log_analytics_workspace.main.primary_shared_key
  }
  sensitive = true
}

#----------------------------------------------------------------------------------------------------------------
# Solutions Outputs
#----------------------------------------------------------------------------------------------------------------

output "container_insights_enabled" {
  description = "Whether Container Insights solution is enabled"
  value       = var.enable_container_insights
}

output "security_center_enabled" {
  description = "Whether Security Center solution is enabled"
  value       = var.enable_security_center
}

output "azure_activity_enabled" {
  description = "Whether Azure Activity solution is enabled"
  value       = var.enable_azure_activity
}