# modules/azure-ai-foundry/main.tf
#----------------------------------------------------------------------------------------------------------------
# 1. Locals for Naming Convention
#----------------------------------------------------------------------------------------------------------------

locals {
  # Construct the base name for Azure AI Foundry
  foundry_name = format(
    "aiq-common-ai-foundry-%s",
    var.project_unique_id
  )
}

#----------------------------------------------------------------------------------------------------------------
# 2. Azure AI Foundry (Cognitive Services Multi-Service Account)
#----------------------------------------------------------------------------------------------------------------
resource "azurerm_cognitive_account" "ai_foundry" {
  name                = local.foundry_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "AIServices"
  sku_name            = "S0"
  
  # Enable public network access
  public_network_access_enabled = true
  
  # Set identity for the cognitive account
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

#----------------------------------------------------------------------------------------------------------------
# 3. GPT-4o Deployment
#----------------------------------------------------------------------------------------------------------------
resource "azurerm_cognitive_deployment" "gpt4" {
  name                 = var.gpt4_deployment_name
  cognitive_account_id = azurerm_cognitive_account.ai_foundry.id

  model {
    format  = "OpenAI"
    name    = var.gpt4_model_name
    version = var.gpt4_model_version
  }

  sku {
    name     = var.gpt4_sku_name
    capacity = var.gpt4_capacity
  }
}

#----------------------------------------------------------------------------------------------------------------
# 4. Text Embedding Ada 002 Deployment
#----------------------------------------------------------------------------------------------------------------
resource "azurerm_cognitive_deployment" "embedding" {
  name                 = var.embedding_deployment_name
  cognitive_account_id = azurerm_cognitive_account.ai_foundry.id

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