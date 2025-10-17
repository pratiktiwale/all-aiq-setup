#-------------------------------------------------------------------------------------------------------------------------------
# local variables and resources for Blob Storage
#-------------------------------------------------------------------------------------------------------------------------------

locals {
  # aiq-{env}-{service_type}-{number} -> remove hyphens and lowercase for storage account naming rules
  base_name = format("aiq-%s-%s-%s-%s", 
  var.env_code, 
  var.service_type,
  var.project_unique_id, 
  var.resource_number)

  storage_account_name = lower(replace(local.base_name, "-", ""))
}

#-------------------------------------------------------------------------------------------------------------------------------
# Blob Storage Resources
#-------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_storage_account" "main" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  is_hns_enabled           = var.is_hns_enabled
  tags                     = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

#-------------------------------------------------------------------------------------------------------------------------------
# Blob Storage Containers
#-------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_storage_container" "containers" {
  count                = length(var.container_names)
  name                 = var.container_names[count.index]
  storage_account_id   = azurerm_storage_account.main.id
  container_access_type = var.container_access_type
}
