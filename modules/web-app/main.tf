# modules/web-app/main.tf
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------

locals {
  # Construct the base name: aiq-{env}-{service-type}-{resource-use}-{number}
  base_name = format(
    "aiq-%s-%s-%s-%s-%s",
    var.service_type,
    var.env_code,
    var.resource_use,
    var.project_unique_id,
    var.resource_number
  )
  # App Service names must be globally unique and lowercase
  app_service_name      = lower(local.base_name)
  
}


#----------------------------------------------------------------------------------------------------------------
# 2. App Service 
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_linux_web_app" "main" {
  name                = local.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # CRITICAL: Reference the new resource block name
  service_plan_id = var.service_plan_id
  tags                = var.tags

   site_config {
    application_stack {
      docker_image_name             = "${var.image_name}:${var.image_tag}"
      # Registry attributes belong inside application_stack for container apps
      docker_registry_url          = var.docker_registry_url
      docker_registry_username     = var.docker_username
      docker_registry_password     = var.docker_password
    }
  }

  # Merge in the Application Insights connection string if enabled
  app_settings = merge({
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  },
    var.app_settings,
    (var.enable_app_insights ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights[0].connection_string
    } : {})
  )
}

# Optional Application Insights resource. Created only if enable_app_insights is true.
resource "azurerm_application_insights" "appinsights" {
  count               = var.enable_app_insights ? 1 : 0
  name                = format("%s-ai", local.app_service_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  
  # Link to Log Analytics Workspace if provided
  workspace_id = var.log_analytics_workspace_id
  
  tags = var.tags
}




