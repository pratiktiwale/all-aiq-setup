# modules/function-app/main.tf
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
  
  # Function App names must be globally unique and lowercase
  function_app_name = lower(local.base_name)
  
  # Storage account name (must be globally unique, lowercase, no hyphens)
  storage_account_name = lower(replace("aiq${var.env_code}funcst${var.project_unique_id}${var.resource_number}", "-", ""))
}

#----------------------------------------------------------------------------------------------------------------
# 2. Storage Account (Required for Function App)
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_storage_account" "function_storage" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = var.tags
}

resource "azurerm_storage_container" "deployments" {
  name                  = "function-deployments"
  storage_account_id    = azurerm_storage_account.function_storage.id
  container_access_type = "private"
}

#----------------------------------------------------------------------------------------------------------------
# 3. Application Insights
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_application_insights" "function_insights" {
  count               = var.enable_app_insights ? 1 : 0
  name                = "${local.function_app_name}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  
  # Link to Log Analytics Workspace if provided
  workspace_id = var.log_analytics_workspace_id
  
  tags = var.tags
}

#----------------------------------------------------------------------------------------------------------------
# 4. Service Plan (Flex Consumption)
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_service_plan" "flex_consumption" {
  name                = "${local.function_app_name}-plan"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "FC1"
  
  tags = var.tags
}

#----------------------------------------------------------------------------------------------------------------
# 5. Flex Consumption Function App
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_function_app_flex_consumption" "main" {
  name                = local.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.flex_consumption.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.function_storage.primary_blob_endpoint}${azurerm_storage_container.deployments.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.function_storage.primary_access_key
  
  runtime_name           = "python"
  runtime_version        = "3.11"
  instance_memory_in_mb  = 512
  maximum_instance_count = var.maximum_instance_count
  
  tags = var.tags
  
  site_config {}

  app_settings = merge({
    # Application Insights settings
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.enable_app_insights ? azurerm_application_insights.function_insights[0].connection_string : ""
    "APPINSIGHTS_INSTRUMENTATIONKEY"       = var.enable_app_insights ? azurerm_application_insights.function_insights[0].instrumentation_key : ""
  },
  # Add user-defined environment variables
  var.app_settings
  )
}
