# modules/log-analytics-workspace/main.tf
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------

locals {
  # Construct the base name: aiq-{env}-{service-type}-{project_unique_id}-{number}
  base_name = format(
    "aiq-%s-%s-%s-%s",
    var.env_code,
    var.service_type,
    var.project_unique_id,
    var.resource_number
  )
  
  # Log Analytics Workspace names must be globally unique and lowercase
  workspace_name = lower(local.base_name)
}

#----------------------------------------------------------------------------------------------------------------
# 2. Log Analytics Workspace
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = local.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb
  
  # Enable internet ingestion and query if specified
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  
  tags = var.tags
}

#----------------------------------------------------------------------------------------------------------------
# 3. Log Analytics Solutions (Optional)
#----------------------------------------------------------------------------------------------------------------

# Container Insights Solution
resource "azurerm_log_analytics_solution" "container_insights" {
  count                 = var.enable_container_insights ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# Security Center Solution
resource "azurerm_log_analytics_solution" "security_center" {
  count                 = var.enable_security_center ? 1 : 0
  solution_name         = "Security"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}

# Azure Activity Solution
resource "azurerm_log_analytics_solution" "azure_activity" {
  count                 = var.enable_azure_activity ? 1 : 0
  solution_name         = "AzureActivity"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureActivity"
  }
}