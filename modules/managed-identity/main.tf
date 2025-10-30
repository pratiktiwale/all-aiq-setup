# modules/managed-identity/main.tf
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------

locals {
  # Construct the base name: aiq-{env}-{service-type}-{resource-use}-{project_unique_id}-{number}
  base_name = format(
    "aiq-common-%s-%s-%s",
    
    var.service_type,
    var.project_unique_id,
    var.resource_number
  )
  
  # Managed Identity name (lowercase)
  managed_identity_name = lower(local.base_name)
}

#----------------------------------------------------------------------------------------------------------------
# 2. User Assigned Managed Identity
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "main" {
  name                = local.managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}