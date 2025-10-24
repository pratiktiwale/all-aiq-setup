# modules/acr/main.tf

#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------

locals {
  # Construct the ACR name by combining components and removing hyphens for global uniqueness (ACR names are restrictive)
  # Example: aiq-iaac-dev-core-01 -> aiqiaacdevcore01
  base_name = format(
    "aiqcommon%s%s",
    "acr", # Hardcoded service type for ACR
    var.project_unique_id,
    
  )
  acr_name = lower(local.base_name)
}

#----------------------------------------------------------------------------------------------------------------
# 2. Container Registry Resource
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  tags                = var.tags
  
  # CRITICAL: Enable the Admin User to provide username/password access to the Web Apps
  admin_enabled       = true 
}