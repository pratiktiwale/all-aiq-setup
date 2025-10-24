# Environment and basic configuration
environment = "Dev"
usage       = "Internal"

# Soft Delete Configuration
enable_soft_delete_protection = false # Set to false for immediate permanent deletion
soft_delete_retention_days    = 1     # Minimum retention period
enable_purge_protection       = false # Set to false to allow immediate purging

# Azure DevOps Configuration  
azure_devops_org_url = "https://dev.azure.com/your-org"
azure_devops_pat     = "dummy-pat-token"
azure_devops_project = "your-project"

# SharePoint Configuration
azure_sharepoint_domain                = "your-domain.sharepoint.com"
azure_sharepoint_site_name             = "your-site"
azure_sharepoint_document_library_name = "Documents"
sharepoint_site_url                    = "https://your-domain.sharepoint.com/sites/your-site"

# Storage Configuration
azure_storage_container_name = "documents"

# Search Configuration
azure_search_index_name = "aiq-index"

# Authentication
azure_client_secret_backup = "dummy-secret"
required_group_id          = "00000000-0000-0000-0000-000000000000"

# Licensing
keygen_public_key = "dummy-key"
license_key       = "dummy-license"