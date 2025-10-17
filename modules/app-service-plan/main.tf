# modules/app-service-plan/main.tf
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------

locals {
  # Naming Convention: aiq-plan-{resource-use}-{number}
  base_name = format(
    "aiq-common-%s",
    var.resource_number
  )
  app_service_plan_name = format("%s-shared-plan", local.base_name)
}

#----------------------------------------------------------------------------------------------------------------
# 2. App Service Plan Resource
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_service_plan" "main" { 
  name                = local.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux" 
  tags                = var.tags
  sku_name            = var.sku_name

  lifecycle {
    create_before_destroy = true
  }
}