# modules/function-app/main.tf
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------
locals {
  # Construct the base name: aiq-{env}-{service-type}-{resource-use}-{project_unique_id}-{number}
  base_name = format(
    "aiq-%s-%s-%s-%s",
    var.env_code,
    var.service_type,
    var.project_unique_id,
    var.resource_number
  )
  
  # Function App names must be globally unique and lowercase
  function_app_name = lower(local.base_name)
  
}

#----------------------------------------------------------------------------------------------------------------
# 2. Service Plan (Basic)
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_service_plan" "basic" {
  name                = "aiq-funcapp-basic-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"  # Basic plan SKU (smallest basic tier)
  
  tags = var.tags
}

#----------------------------------------------------------------------------------------------------------------
# 3. Storage Account (Required for Function App)
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_storage_account" "function_storage" {
  name                     = "aiqfuncstorage"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#----------------------------------------------------------------------------------------------------------------
# 4. Application Insights
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_application_insights" "function_insights" {
  name                = "${local.function_app_name}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  
  # Link to Log Analytics Workspace if provided
  workspace_id = var.log_analytics_workspace_id
  
  tags = var.tags
}

#----------------------------------------------------------------------------------------------------------------
# 5. Linux Function App with Premium Plan
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_linux_function_app" "main" {
  name                       = local.function_app_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.basic.id
  
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  
  tags = var.tags
  
  site_config {
    # Application Insights config
    application_insights_key               = azurerm_application_insights.function_insights.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.function_insights.connection_string
    
    # Application stack configuration
    application_stack {
      python_version = "3.11"
    }
    
    # Premium plan configuration
    ftps_state        = "Disabled"
    use_32_bit_worker = false
  }

  # Environment variables and application settings
  app_settings = merge({
    # Required Function App settings
    "FUNCTIONS_WORKER_RUNTIME"     = "python"
    "FUNCTIONS_EXTENSION_VERSION"  = "~4"
    "WEBSITE_RUN_FROM_PACKAGE"     = "1"
    
    # Python version specification
    "PYTHON_VERSION"               = "3.11"
    
    # Storage connection string
    "AzureWebJobsStorage" = azurerm_storage_account.function_storage.primary_connection_string
    
    # Application Insights settings
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.function_insights.connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY"       = azurerm_application_insights.function_insights.instrumentation_key
  },
  # Add user-defined environment variables
  var.app_settings
  )
}