
#--------------------------------------------------------------------------------------------------------------------------------
# Create a Resource Group
#--------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Managed Identity Module Call
#--------------------------------------------------------------------------------------------------------------------------------

module "managed_identity" {
  source = "./modules/managed-identity"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  # Naming Convention Components: aiq-{env}-mi-general-{project_unique_id}-01

  service_type      = "umi"
  project_unique_id = var.project_unique_id
  resource_number   = "01"

  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Shared App Service Plan Call 
#--------------------------------------------------------------------------------------------------------------------------------

module "shared_plan" {
  source              = "./modules/app-service-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  # Naming Components
  resource_number = "01"

  # The required B3 SKU
  sku_name = "B3"

  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Redis Cache Module Call
#--------------------------------------------------------------------------------------------------------------------------------
module "redis_cache" {
  source              = "./modules/redis-cache"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location


  resource_number = "01"

  # Redis sizing - adjust for your environment
  sku_name = "Standard"
  family   = "C"
  capacity = 0

  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}



#--------------------------------------------------------------------------------------------------------------------------------
# Cosmos DB Module Call (Creates the database and containers)
#--------------------------------------------------------------------------------------------------------------------------------

module "cosmosdb" {
  source = "./modules/cosmosdb" # Path to your module directory

  # Core Infrastructure Variables
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  # Naming Convention Components: aiq-{env}-cosmosdb-be-01
  env_code        = var.environment # Value from root/variables.tf (e.g., "iaac-dev")
  service_type    = "cosmosdb"      # Hardcoded string value (matches default in module, but good practice to be explicit)
  resource_use    = "be"            # Resource Use (Backend uses the DB)
  resource_number = "01"            # Number suffix


  # Resource Configuration
  # sql_database_name = "${var.env}-DB" # Database name (not part of the global resource name)

  # Tags (Passed to the module to be applied to the Cosmos DB account)
  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}


#--------------------------------------------------------------------------------------------------------------------------------
# Backend API Module Call (Uses modules/web-app)
#--------------------------------------------------------------------------------------------------------------------------------

module "backend_api" {
  source = "./modules/web-app"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  image_name          = module.acr.backend_repository_name
  acr_login_server    = module.acr.login_server

  # Naming Convention Components: aiq-{env}-webapp-be-01
  env_code          = var.environment
  service_type      = "webapp"
  resource_use      = "be"
  project_unique_id = var.project_unique_id
  resource_number   = "01"

  # CONTAINER CONFIGURATION (MAPPING ACR Outputs)
  docker_image_name      = "${module.acr.backend_repository_name}:v1.0"
  docker_registry_url    = "https://${module.acr.login_server}"
  docker_username        = module.acr.admin_username
  docker_password        = module.acr.admin_password
  docker_startup_command = "null"


  # App Configuration
  service_plan_id = module.shared_plan.id
  runtime_stack   = "PYTHON|3.11"

  # Define environment variables (app_settings)
  app_settings = {
    # CRITICAL: Wire the Cosmos DB output here
    "COSMOS_CONNECTION_STRING" = module.cosmosdb.primary_connection_string
    "LOG_LEVEL"                = "Warning"
    "API_TIMEOUT_SECONDS"      = "30"
  }

  # Tags
  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
  enable_app_insights = true
}

#--------------------------------------------------------------------------------------------------------------------------------
# Frontend App Module Call (Uses modules/web-app)
#--------------------------------------------------------------------------------------------------------------------------------

module "frontend_app" {
  source = "./modules/web-app"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  image_name          = module.acr.frontend_repository_name
  acr_login_server    = module.acr.login_server

  # Naming Convention Components: aiq-{env}-webapp-fe-01
  env_code          = var.environment
  service_type      = "webapp"
  resource_use      = "fe"
  project_unique_id = var.project_unique_id
  resource_number   = "01"


  # CONTAINER CONFIGURATION (Mapping ACR Outputs)
  docker_image_name      = "${module.acr.frontend_repository_name}:v1.0"
  docker_registry_url    = "https://${module.acr.login_server}"
  docker_username        = module.acr.admin_username
  docker_password        = module.acr.admin_password
  docker_startup_command = null

  # App Configuration
  service_plan_id = module.shared_plan.id
  runtime_stack   = "PYTHON|3.11"

  # Define environment variables (app_settings)
  app_settings = {
    # CRITICAL: Wire the Backend API hostname here
    "VITE_API_BASE_URL" = "https://${module.backend_api.default_hostname}"
    "UI_THEME"          = "dark"
    "FEATURE_TOGGLE_A"  = "true"
  }

  # Tags
  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
  enable_app_insights = true
}

#--------------------------------------------------------------------------------------------------------------------------------
# Azure Container Registry
#--------------------------------------------------------------------------------------------------------------------------------
module "acr" {
  source              = "./modules/container-registry" # Path to your ACR module
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  # Naming Convention Components (aiq-{env}-acr-{resource-use}-{number})
  project_unique_id = var.project_unique_id
  resource_number   = "01" # Number suffix

  # ACR Configuration
  sku = "Premium" # Use Basic SKU for development/cost efficiency

  # Tags
  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Blob Storage Module Call
#--------------------------------------------------------------------------------------------------------------------------------
module "blob_storage" {
  source              = "./modules/blob-storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  # Naming components
  env_code          = var.environment
  service_type      = "blob"
  project_unique_id = var.project_unique_id
  resource_number   = "01"

  # Example containers - change as needed
  container_names = ["uploads", "logs"]

  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}


#--------------------------------------------------------------------------------------------------------------------------------
# Azure OpenAI Module Call
#--------------------------------------------------------------------------------------------------------------------------------



module "azure_openai" {
  source = "./modules/azure_openai"

  location            = "East US"
  resource_group_name = azurerm_resource_group.main.name

  service_type      = "openai"
  resource_use      = "ai"
  project_unique_id = var.project_unique_id

  gpt_deployment_name  = "gpt-4o-deployment"
  gpt_model_name       = "gpt-4o"
  gpt_model_version    = "2024-08-06"
  gpt_sku_name         = "Standard"
  gpt_capacity         = 49
  gpt_rate_limit_count = 49000

  embedding_deployment_name  = "text-embedding-ada-002"
  embedding_model_name       = "text-embedding-ada-002"
  embedding_model_version    = "2"
  embedding_sku_name         = "Standard"
  embedding_capacity         = 119
  embedding_rate_limit_count = 119000
}


#--------------------------------------------------------------------------------------------------------------------------------
# Azure AI Search Module Call
#--------------------------------------------------------------------------------------------------------------------------------


module "azure_ai_search" {
  source = "./modules/azure-ai-search"

  location = var.location
  # Reference the resource group's name resource so Terraform enforces creation order
  resource_group_name = azurerm_resource_group.main.name

  env_code        = var.environment
  service_type    = "search"
  resource_number = "02"

  project_unique_id = var.project_unique_id


  # Index Configuration - enabled for search index creation
  index_name   = "aiq-index"
  create_index = true

  # Azure OpenAI Configuration for Vector Search (if needed later)
  openai_resource_uri  = module.azure_openai.endpoint
  openai_deployment_id = module.azure_openai.embedding_deployment_name
  openai_model_name    = "text-embedding-ada-002"

  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Key Vault Module Call
#--------------------------------------------------------------------------------------------------------------------------------

module "key_vault" {
  source = "./modules/key-vault"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  # Naming Convention Components: aiq-common-kv-{project_unique_id}-01
  service_type      = "kv"
  project_unique_id = var.project_unique_id
  resource_number   = "01"

  # Example secrets - you can customize these or pass them as variables
  secrets = {
    "openai-endpoint" = module.azure_openai.endpoint
    "openai-api-key"  = module.azure_openai.primary_access_key
  }

  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# function app module call
#--------------------------------------------------------------------------------------------------------------------------------

module "function_app" {
  source = "./modules/function-app"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  env_code        = var.environment
  service_type    = "function"
  resource_use    = "function"
  resource_number = "01"

  project_unique_id = var.project_unique_id

  tags = {
    "Usage"       = "Internal"
    "Environment" = "IAAC-${var.env}"
  }
  enable_app_insights = true
}

#--------------------------------------------------------------------------------------------------------------------------------
# Role Assignments for Managed Identity
#--------------------------------------------------------------------------------------------------------------------------------

# Resource Group - Reader Role
resource "azurerm_role_assignment" "managed_identity_rg_reader" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure Storage Account - Storage Blob Data Contributor
resource "azurerm_role_assignment" "managed_identity_storage_contributor" {
  scope                = module.blob_storage.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure Container Registry - AcrPull
resource "azurerm_role_assignment" "managed_identity_acr_pull" {
  scope                = module.acr.registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure Key Vault - Key Vault Secrets User
resource "azurerm_role_assignment" "managed_identity_keyvault_secrets" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure Cosmos DB Account - Cosmos DB Account Reader Role
resource "azurerm_role_assignment" "managed_identity_cosmosdb_reader" {
  scope                = module.cosmosdb.cosmosdb_account_id
  role_definition_name = "Cosmos DB Account Reader Role"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure AI Search Service - Search Index Data Contributor
resource "azurerm_role_assignment" "managed_identity_search_contributor" {
  scope                = module.azure_ai_search.search_service_id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure OpenAI Service - Cognitive Services Contributor
resource "azurerm_role_assignment" "managed_identity_openai_contributor" {
  scope                = module.azure_openai.cognitive_account_id
  role_definition_name = "Cognitive Services Contributor"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure OpenAI Service - Cognitive Services OpenAI Contributor
resource "azurerm_role_assignment" "managed_identity_openai_openai_contributor" {
  scope                = module.azure_openai.cognitive_account_id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure Cache for Redis - Azure Cache for Redis Contributor
resource "azurerm_role_assignment" "managed_identity_redis_contributor" {
  scope                = module.redis_cache.id
  role_definition_name = "Azure Cache for Redis Contributor"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

#--------------------------------------------------------------------------------------------------------------------------------
# App Registration Module Call
#--------------------------------------------------------------------------------------------------------------------------------

module "app_registration" {
  source = "./modules/app-registration"
  
  # Naming Convention Components: aiq-{env}-app-{resource_use}-{project_unique_id}-01
  env_code          = var.environment
  service_type      = "app"
  resource_use      = "prod"  # or "dev", "test" based on environment
  project_unique_id = var.project_unique_id
  resource_number   = "01"
  
  # App registration configuration
  description = "AIQ Application Registration for ${var.project_unique_id} project"
  
  # Web App Service URLs (to be added when available)
  backend_web_app_url  = try(module.backend_api.app_service_url, "")
  frontend_web_app_url = try(module.frontend_app.app_service_url, "")
  
  # Generate a unique UUID for the app scope
  app_scope_id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"  # Generate unique UUID
  
  client_secret_end_date = "2025-12-31T23:59:59Z"
}


#--------------------------------------------------------------------------------------------------------------------------------
