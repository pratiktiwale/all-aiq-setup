
#--------------------------------------------------------------------------------------------------------------------------------
# Create a Resource Group
#--------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
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
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Log Analytics Workspace Module Call
#--------------------------------------------------------------------------------------------------------------------------------

module "log_analytics_workspace" {
  source = "./modules/log-analytics-workspace"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  # Naming Convention Components: aiq-{env}-law-{project_unique_id}-01
  env_code          = lower(var.environment)
  service_type      = "law"
  project_unique_id = var.project_unique_id
  resource_number   = "01"

  # Log Analytics Configuration
  sku                        = "PerGB2018"
  retention_in_days          = 30
  daily_quota_gb             = -1
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  # Enable solutions
  enable_container_insights = true
  enable_security_center    = true
  enable_azure_activity     = true

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
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
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
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

  # Pass the managed identity principal ID for data access policy
  managed_identity_principal_id = module.managed_identity.managed_identity_principal_id

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
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

  # Naming Convention Components: aiq-{env}-cosmos-1
  env_code        = lower(var.environment) # Convert to lowercase for naming (e.g., "dev", "prod")
  service_type    = "cosmosdb"             # Hardcoded string value (matches default in module, but good practice to be explicit)
  resource_use    = "be"                   # Resource Use (Backend uses the DB)
  resource_number = "1"                    # Number suffix (matches documentation format)

  # Pass the managed identity principal ID for Data Plane RBAC
  managed_identity_principal_id = module.managed_identity.managed_identity_principal_id

  # Resource Configuration
  # sql_database_name = "${var.env}-DB" # Database name (not part of the global resource name)

  # Tags (Passed to the module to be applied to the Cosmos DB account)
  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
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
  env_code          = lower(var.environment)
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
  # Python version is specified in the Docker image, not runtime_stack

  # Define environment variables (app_settings)
  app_settings = {
    # App Registration and Authentication
    #"API_AUDIENCE"      = "api://${module.app_registration.application_id}"
    #"APP_ID_URI"        = "api://${module.app_registration.application_id}"
    #"CLIENT_ID"         = module.app_registration.application_id
    #"OPENAPI_CLIENT_ID" = module.app_registration.application_id
    "TENANT_ID"         = var.tenant_id
    "REQUIRED_GROUP_ID" = var.required_group_id

    # Application Environment
    "APP_ENV"      = "cloud"
    "USE_KEYVAULT" = "TRUE"

    # Azure DevOps Configuration
    "AZURE_DEVOPS_ORG_URL" = var.azure_devops_org_url
    "AZURE_DEVOPS_PAT"     = var.azure_devops_pat
    "AZURE_DEVOPS_PROJECT" = var.azure_devops_project

    # Key Vault
    "AZURE_KEY_VAULT_NAME" = module.key_vault.key_vault_name

    # Azure OpenAI (using standalone service)
    "AZURE_OPENAI_DEPLOYMENT" = module.azure_openai.embedding_deployment_name
    "AZURE_OPENAI_ENDPOINT"   = module.azure_openai.endpoint

    # Azure AI Foundry
    "AZURE_AI_FOUNDRY_ENDPOINT" = module.azure_ai_foundry.ai_foundry_endpoint

    # Azure Document Intelligence
    "AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT" = module.document_intelligence.endpoint

    # Azure AI Search
    "AZURE_SEARCH_ENDPOINT"   = module.azure_ai_search.search_service_url
    "AZURE_SEARCH_INDEX_NAME" = var.azure_search_index_name
    # Note: AZURE_SEARCH_KEY removed - using RBAC authentication via managed identity

    # SharePoint Configuration
    "AZURE_SHAREPOINT_DOCUMENT_LIBRARY_NAME" = var.azure_sharepoint_document_library_name
    "AZURE_SHAREPOINT_DOMAIN"                = var.azure_sharepoint_domain
    "AZURE_SHAREPOINT_SITE_NAME"             = var.azure_sharepoint_site_name

    # Storage Account
    "AZURE_STORAGE_ACCOUNT_NAME"   = module.blob_storage.storage_account_name
    "AZURE_STORAGE_CONTAINER_NAME" = var.azure_storage_container_name

    # Cosmos DB
    "COSMOS_CONTAINER_NAME"               = "conversations"
    "COSMOS_DATABASE_NAME"                = module.cosmosdb.database_name
    "COSMOS_ENDPOINT"                     = module.cosmosdb.endpoint
    "COSMOS_STARTER_QUERY_CONTAINER_NAME" = "starter_queries"
    "COSMOS_STARTER_QUERY_DATABASE_NAME"  = module.cosmosdb.database_name

    # Pipeline and Processing Configuration
    "INDEXER_PIPELINE_ID"            = "9"
    "INSIGHT_CACHE_TTL_HOURS"        = "12"
    "INSIGHT_CONFIDENCE_THRESHOLD"   = "0.75"
    "INSIGHT_EXTRACTION_ENABLED"     = "FALSE"
    "INSIGHT_MAX_CONCURRENT_SYSTEMS" = "5"
    "INSIGHT_QUERY_TIMEOUT_SECONDS"  = "600"
    "INSIGHT_SCHEDULER_ENABLED"      = "FALSE"

    # Application Insights and Monitoring
    "InstrumentationEngine_EXTENSION_VERSION" = "disabled"

    # License and Review Configuration
    "LICENSE_FILE_PATH"          = "license/license.lic"
    "MODE_OF_REVIEW"             = "multi_pass"
    "SINGLE_PASS_REVIEWER_GROUP" = "content_reviewer_1"

    # Redis Configuration
    "REDIS_DB"   = "0"
    "REDIS_HOST" = module.redis_cache.redis_host
    "REDIS_PORT" = "6380"
    "REDIS_SSL"  = "TRUE"

    # Deployment Configuration
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"

    # Legacy settings
    "LOG_LEVEL"           = "Warning"
    "API_TIMEOUT_SECONDS" = "30"
  }

  # Tags
  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }

  enable_app_insights        = true
  log_analytics_workspace_id = module.log_analytics_workspace.workspace_id
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
  env_code          = lower(var.environment)
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
  # Python version is specified in the Docker image, not runtime_stack

  # Define environment variables (app_settings)
  app_settings = {
    # API Configuration - Backend Web App URL
    "API_URI" = "https://${module.backend_api.default_hostname}/api"

    # Authentication Configuration
    "AUTHORITY" = "https://login.microsoftonline.com/${var.tenant_id}"
    #"CLIENT_ID" = module.app_registration.application_id
    "TENANT_ID" = var.tenant_id

    # Redirect and Scopes Configuration 
    "REDIRECT_URI" = "https://${module.backend_api.default_hostname}/platform/home"
    #"SCOPES"       = "api://${module.app_registration.application_id}/app"

    # App Service Configuration
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "FALSE"

    # Legacy settings (keeping for compatibility)
    "VITE_API_BASE_URL" = "https://${module.backend_api.default_hostname}"
    "UI_THEME"          = "dark"
    "FEATURE_TOGGLE_A"  = "true"
  }

  # Tags
  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }

  enable_app_insights        = true
  log_analytics_workspace_id = module.log_analytics_workspace.workspace_id
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
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
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
  env_code          = lower(var.environment)
  service_type      = "blob"
  project_unique_id = var.project_unique_id
  resource_number   = "01"

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Azure AI Foundry Module Call
#--------------------------------------------------------------------------------------------------------------------------------

module "azure_ai_foundry" {
  source = "./modules/azure-ai-foundry"

  location            = "East US 2"
  resource_group_name = azurerm_resource_group.main.name

  resource_use      = "ai"
  project_unique_id = var.project_unique_id

  # GPT-4o Deployment Configuration
  gpt4_deployment_name = "gpt-4o-foundry"
  gpt4_model_name      = "gpt-4o"
  gpt4_model_version   = "2024-08-06"
  gpt4_sku_name        = "GlobalStandard"
  gpt4_capacity        = 50

  # Text Embedding Ada 002 Deployment Configuration
  embedding_deployment_name = "text-embedding-ada-002-foundry"
  embedding_model_name      = "text-embedding-ada-002"
  embedding_model_version   = "2"
  embedding_sku_name        = "GlobalStandard"
  embedding_capacity        = 120

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Azure OpenAI Service Module Call (Separate - Embedding Only)
#--------------------------------------------------------------------------------------------------------------------------------

module "azure_openai" {
  source = "./modules/azure_openai"

  location            = "East US 2"
  resource_group_name = azurerm_resource_group.main.name

  service_type      = "openai"
  resource_use      = "embed"
  project_unique_id = var.project_unique_id

  # Embedding deployment configuration (only embedding, no GPT)
  embedding_deployment_name = "text-embedding-ada-002-standalone"
  embedding_model_name      = "text-embedding-ada-002"
  embedding_model_version   = "2"
  embedding_sku_name        = "GlobalStandard"
  embedding_capacity        = 120

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Azure AI Search Module Call
#--------------------------------------------------------------------------------------------------------------------------------


module "azure_ai_search" {
  source = "./modules/azure-ai-search"

  location = var.location
  # Reference the resource group's name resource so Terraform enforces creation order
  resource_group_name = azurerm_resource_group.main.name

  service_type      = "search"
  project_unique_id = var.project_unique_id

  # RBAC Configuration - Always enabled for enhanced security
  managed_identity_principal_id = module.managed_identity.managed_identity_principal_id

  # Index Configuration - enabled for search index creation
  index_name   = "aiq-index"
  create_index = true

  # Azure OpenAI Configuration for Vector Search (using standalone service)
  openai_resource_uri  = module.azure_openai.endpoint
  openai_deployment_id = module.azure_openai.embedding_deployment_name
  openai_model_name    = "text-embedding-ada-002"

  # Vectorizer Configuration - Ensures automatic model deployment selection
  openai_endpoint         = module.azure_openai.openai_vectorizer_endpoint
  openai_deployment_name  = module.azure_openai.embedding_deployment_name  # "text-embedding-ada-002-standalone"
  openai_vectorizer_name  = "openai-vectorizer"

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# Azure Document Intelligence Module Call
#--------------------------------------------------------------------------------------------------------------------------------

module "document_intelligence" {
  source = "./modules/document-intelligence"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  env_code          = lower(var.environment)
  project_unique_id = var.project_unique_id

  # Standard pricing tier for Document Intelligence
  sku_name = "S0"

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
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

  # Soft delete configuration
  soft_delete_retention_days = var.enable_soft_delete_protection ? var.soft_delete_retention_days : 7
  purge_protection_enabled   = var.enable_purge_protection

  # Key Vault secrets - mapped to Terraform modules and user inputs
  secrets = {
    # Authentication & App Registration (Already exist - commented out)
    /*"API-AUDIENCE"      = "api://${module.app_registration.application_id}"
    "APP-ID-URI"        = "api://${module.app_registration.application_id}"
    "CLIENT-ID"         = module.app_registration.application_id
    "OPENAPI-CLIENT-ID" = module.app_registration.application_id
    "CLIENT-SECRET"     = module.app_registration.client_secret_value*/
    "TENANT-ID"         = var.tenant_id
    "REQUIRED-GROUP-ID" = var.required_group_id


    "AZURE-DEVOPS-ORG-URL" = var.azure_devops_org_url
    "AZURE-DEVOPS-PAT"     = var.azure_devops_pat


    "AZURE-OPENAI-ENDPOINT" = module.azure_openai.endpoint
    "AZURE-OPENAI-API-KEY"  = module.azure_openai.primary_access_key

    # Azure AI Foundry
    "AZURE-AI-FOUNDRY-ENDPOINT" = module.azure_ai_foundry.ai_foundry_endpoint
    "AZURE-AI-FOUNDRY-API-KEY"  = module.azure_ai_foundry.ai_foundry_primary_key

    # Azure AI Foundry Deployments
    "AZURE-AI-FOUNDRY-GPT4-DEPLOYMENT-NAME"      = module.azure_ai_foundry.gpt4_deployment_name
    "AZURE-AI-FOUNDRY-EMBEDDING-DEPLOYMENT-NAME" = module.azure_ai_foundry.embedding_deployment_name

    # Azure Document Intelligence
    "AZURE-DOCUMENT-INTELLIGENCE-ENDPOINT" = module.document_intelligence.endpoint
    "AZURE-DOCUMENT-INTELLIGENCE-API-KEY"  = module.document_intelligence.primary_access_key

    "AZURE-SEARCH-ENDPOINT" = module.azure_ai_search.search_service_url
    # Note: AZURE-SEARCH-KEY removed - using RBAC authentication via managed identity


    "AZURE-STORAGE-ACCOUNT-KEY" = module.blob_storage.primary_access_key


    "COSMOS-ENDPOINT"    = module.cosmosdb.endpoint
    "COSMOS-PRIMARY-KEY" = module.cosmosdb.primary_key

    "DOCKER-REGISTRY-SERVER-PASSWORD" = module.acr.admin_password

    "REDIS-PASSWORD" = module.redis_cache.redis_primary_key

    "KEYGEN-PUBLIC-KEY" = var.keygen_public_key
    "LICENSE-KEY"       = var.license_key
  }

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# function app module call
#--------------------------------------------------------------------------------------------------------------------------------

module "function_app" {
  source = "./modules/function-app"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  env_code        = lower(var.environment)
  service_type    = "function"
  resource_number = "01"

  project_unique_id = var.project_unique_id

  # Function App Environment Variables
  app_settings = {
    # Application Insights (will be overridden by module's built-in setting)
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "" # Module handles this automatically

    # Azure Blob Storage
    "AZURE_BLOB_CONTAINER_NAME"      = var.azure_storage_container_name
    "AZURE_BLOB_STORAGE_ACCOUNT_URL" = "https://${module.blob_storage.storage_account_name}.blob.core.windows.net"

    # Azure Authentication
    /*"AZURE_CLIENT_ID"            = module.app_registration.application_id
    "AZURE_CLIENT_SECRET_BACKUP" = var.azure_client_secret_backup*/
    "AZURE_TENANT_ID" = var.tenant_id

    # Azure Document Intelligence
    "AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT" = module.document_intelligence.endpoint

    # Azure OpenAI (using standalone service)
    "AZURE_OPENAI_ENDPOINT" = module.azure_openai.endpoint

    # Azure AI Search
    "AZURE_SEARCH_ENDPOINT"   = module.azure_ai_search.search_service_url
    "AZURE_SEARCH_INDEX_NAME" = var.azure_search_index_name

    # SharePoint Configuration
    "AZURE_SHAREPOINT_DOCUMENT_LIBRARY_NAME" = var.azure_sharepoint_document_library_name
    "AZURE_SHAREPOINT_DOMAIN"                = var.azure_sharepoint_domain
    "AZURE_SHAREPOINT_SITE_NAME"             = var.azure_sharepoint_site_name

    # Storage (will be overridden by module's built-in setting)
    "AzureWebJobsStorage" = "" # Module handles this automatically

    # Processing Configuration
    "BATCH_SIZE"         = "200"
    "GRAPH_TIMEOUT"      = "10"
    "OCR_CHAR_THRESHOLD" = "100"
    "TOKEN_SKEW"         = "300"

    # Cosmos DB
    "COSMOS_CONTAINER_NAME" = "conversations"
    "COSMOS_DB_NAME"        = module.cosmosdb.database_name
    "COSMOS_ENDPOINT"       = module.cosmosdb.endpoint
    "COSMOS_KEY"            = module.cosmosdb.primary_key

    # Deployment Storage
    "DEPLOYMENT_STORAGE_CONNECTION_STRING" = module.blob_storage.primary_connection_string

    # Docker Configuration
    "DOCKER_ENABLE_CI"                = "true"
    "DOCKER_REGISTRY_SERVER_PASSWORD" = module.acr.admin_password
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${module.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = module.acr.admin_username

    # AI Model Configuration
    "EMBEDDING_DEPLOYMENT_ID" = "text-embedding-ada-002"

    # SharePoint Site URL
    "SHAREPOINT_SITE_URL" = var.sharepoint_site_url

    # User Managed Identity
    "UMI_CLIENT_ID" = module.managed_identity.managed_identity_client_id
  }

  tags = {
    "Usage"       = var.usage
    "Environment" = "IAAC-${var.environment}"
  }

  enable_app_insights        = true
  log_analytics_workspace_id = module.log_analytics_workspace.workspace_id
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

# Azure Cache for Redis - Redis Cache Contributor
resource "azurerm_role_assignment" "managed_identity_redis_contributor" {
  scope                = module.redis_cache.id
  role_definition_name = "Redis Cache Contributor"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure AI Search System Identity - Access to OpenAI for Vectorizers (kept for vectorizer functionality)
resource "azurerm_role_assignment" "search_openai_user" {
  scope                = module.azure_openai.cognitive_account_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.azure_ai_search.search_service_principal_id
}

# Managed Identity - Access to OpenAI for vectorizer operations
resource "azurerm_role_assignment" "managed_identity_openai_user" {
  scope                = module.azure_openai.cognitive_account_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Search Index Data Reader - Resource Group Access
resource "azurerm_role_assignment" "search_index_data_reader_rg" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Search Index Data Reader"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure AI Foundry - Cognitive Services Contributor Access
resource "azurerm_role_assignment" "managed_identity_ai_foundry_contributor" {
  scope                = module.azure_ai_foundry.ai_foundry_id
  role_definition_name = "Cognitive Services Contributor"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure AI Foundry - Cognitive Services OpenAI Contributor Access
resource "azurerm_role_assignment" "managed_identity_ai_foundry_openai_contributor" {
  scope                = module.azure_ai_foundry.ai_foundry_id
  role_definition_name = "Cognitive Services OpenAI Contributor"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure AI Foundry - Cognitive Services User Access
resource "azurerm_role_assignment" "managed_identity_ai_foundry_user" {
  scope                = module.azure_ai_foundry.ai_foundry_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure AI Foundry - Azure AI Account Owner Access (First assignment)
resource "azurerm_role_assignment" "managed_identity_ai_foundry_account_owner_1" {
  scope                = module.azure_ai_foundry.ai_foundry_id
  role_definition_name = "Azure AI Account Owner"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure AI Foundry - Cognitive Services OpenAI User Access
resource "azurerm_role_assignment" "managed_identity_ai_foundry_openai_user" {
  scope                = module.azure_ai_foundry.ai_foundry_id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Search Service - Azure AI Account Owner Access
resource "azurerm_role_assignment" "search_service_ai_account_owner" {
  scope                = module.azure_ai_search.search_service_id
  role_definition_name = "Azure AI Account Owner"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure Document Intelligence - Cognitive Services User Access (for Function App)
resource "azurerm_role_assignment" "managed_identity_document_intelligence_user" {
  scope                = module.document_intelligence.document_intelligence_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.managed_identity.managed_identity_principal_id
}

# Azure Blob Storage - Storage Blob Data Reader Access (for preview functionality)
resource "azurerm_role_assignment" "managed_identity_storage_blob_reader" {
  scope                = module.blob_storage.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = module.managed_identity.managed_identity_principal_id
}



/*
#--------------------------------------------------------------------------------------------------------------------------------
# App Registration Module Call
#--------------------------------------------------------------------------------------------------------------------------------

module "app_registration" {
  source = "./modules/app-registration"

  # Naming Convention Components: aiq-{env}-app-{resource_use}-{project_unique_id}-01

  service_type      = "app-registration"
  project_unique_id = var.project_unique_id

  # App registration configuration
  description = "AIQ Application Registration for ${var.project_unique_id} project"

  # Web App Service URLs (placeholder to avoid circular dependency)
  backend_web_app_url  = ""
  frontend_web_app_url = ""

  # Generate a unique UUID for the app scope
  app_scope_id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890" # Generate unique UUID

  client_secret_end_date = "2025-12-31T23:59:59Z"
}


#--------------------------------------------------------------------------------------------------------------------------------
*/