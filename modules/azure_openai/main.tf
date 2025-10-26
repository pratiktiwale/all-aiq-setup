
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------
locals {
  # Construct the base name: aiq-{env}-{service-type}-{resource-use}-{number}
  base_name = format(
    "aiq-common-%s-%s-%s",  
    var.service_type,
    var.resource_use,
    var.project_unique_id,
  )
  # App Service names must be globally unique and lowercase
  azurerm_cognitive_account_name      = lower(local.base_name)
  
}

#----------------------------------------------------------------------------------------------------------------
# 2. Azure OpenAI Resources
#---------------------------------------------------------------------------------------------------------------- 

resource "azurerm_cognitive_account" "openai" {
  name                = local.azurerm_cognitive_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"
  
  # Enable public network access for vectorizer integration
  public_network_access_enabled = true
  
  # Set identity for the cognitive account
  identity {
    type = "SystemAssigned"
  }
  
  tags                = var.tags
}

#----------------------------------------------------------------------------------------------------------------
# 3. Azure OpenAI Embedding Deployment
#---------------------------------------------------------------------------------------------------------------- 

resource "azurerm_cognitive_deployment" "embedding" {
  name                 = var.embedding_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = var.embedding_model_name
    version = var.embedding_model_version
  }

  sku {
    name     = var.embedding_sku_name
    capacity = var.embedding_capacity
  }
}
