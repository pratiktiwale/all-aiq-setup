#-------------------------------------------------------------------------------------------------------------------------------
# local variables and resources for Key Vault
#-------------------------------------------------------------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

locals {
  # aiq-common-{service_type}-{project_unique_id}-{number}
  base_name = format("aiq-common-%s-%s-%s", 
  var.service_type,
  var.project_unique_id, 
  var.resource_number)

  # Key Vault names must be globally unique and can contain only alphanumeric and hyphens
  key_vault_name = substr(local.base_name, 0, 24) # Key vault names must be 3-24 characters
}

#-------------------------------------------------------------------------------------------------------------------------------
# Key Vault Resources
#-------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_key_vault" "main" {
  name                = local.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  
  # Soft delete and purge protection settings
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  
  tags = var.tags

  # Default access policy for the current user/service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
      "Recover",
      "Purge",
      "GetRotationPolicy",
      "SetRotationPolicy"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]
  }
}

#-------------------------------------------------------------------------------------------------------------------------------
# Key Vault Secrets
#-------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.main.id
  
  tags = var.tags

  depends_on = [azurerm_key_vault.main]
}