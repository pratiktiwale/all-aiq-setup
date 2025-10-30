# modules/document-intelligence/main.tf
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------

locals {
  # Construct the base name: aiq-{env}-docint-{project_unique_id}-01
  base_name = format(
    "aiq-common-docint-lrm",     
  )
  
  # Document Intelligence service name must be globally unique and lowercase
  service_name = lower(local.base_name)
}

#----------------------------------------------------------------------------------------------------------------
# 2. Azure Document Intelligence (Cognitive Service)
#----------------------------------------------------------------------------------------------------------------

resource "azurerm_cognitive_account" "document_intelligence" {
  name                = local.service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FormRecognizer"  # Document Intelligence service type
  sku_name            = var.sku_name
  
  # Enable public network access
  public_network_access_enabled = true
  
  tags = var.tags
}