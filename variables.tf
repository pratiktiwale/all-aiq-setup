variable "resource_group_name" {
  description = "The name of the Azure Resource Group to create (e.g., aiq-rg-common-eastus-01)."
  type        = string
  default     = "aiq-internal-iaac-rg"
}

variable "subscription_id" {
  description = "The Azure subscription ID to deploy resources to"
  type        = string
  default     = "58ace139-af0e-4d71-83b4-8dece6cf8331"
}

variable "location" {
  description = "The Azure region for deployment."
  type        = string
  default     = "Central India"
}

variable "environment" {
  description = "The environment name (e.g., 'Dev', 'Production', 'Staging'). Will be used as-is for tags and lowercase for naming conventions."
  type        = string
}



variable "usage" {
  description = "The resource usage for the naming convention (e.g., 'Internal')."
  type        = string
}

variable "project_unique_id" {
  description = "A unique, short identifier (e.g., a few random letters/numbers) to guarantee globally unique Web App names."
  type        = string
  default     = "lrm"
}

# Authentication and App Registration Variables
variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
  default     = "5d0af39e-31d1-4069-9243-c30c29346af7"
  sensitive   = true
}

variable "required_group_id" {
  description = "The required Azure AD group ID for authentication"
  type        = string
  sensitive   = true
}

# Azure DevOps Configuration
variable "azure_devops_org_url" {
  description = "The Azure DevOps organization URL"
  type        = string
  default     = "https://dev.azure.com/LeftRightMind-DevOps"
  sensitive   = true
}

variable "azure_devops_pat" {
  description = "The Azure DevOps Personal Access Token"
  type        = string
  sensitive   = true
}

variable "azure_devops_project" {
  description = "The Azure DevOps project name"
  type        = string
}

# Azure AI Search Configuration
variable "azure_search_index_name" {
  description = "The name of the Azure AI Search index"
  type        = string
  default     = "documents"
}

# SharePoint Configuration
variable "azure_sharepoint_document_library_name" {
  description = "The name of the SharePoint document library"
  type        = string
  default     = "Documents"
}

variable "azure_sharepoint_domain" {
  description = "The SharePoint domain URL"
  type        = string
  sensitive   = true
}

variable "azure_sharepoint_site_name" {
  description = "The SharePoint site name"
  type        = string
}

# Storage Configuration
variable "azure_storage_container_name" {
  description = "The name of the Azure Storage container"
  type        = string
  default     = "documents"
}

# Function App Specific Variables
variable "azure_client_secret_backup" {
  description = "Backup Azure client secret for function app authentication"
  type        = string
  sensitive   = true
}

variable "sharepoint_site_url" {
  description = "The complete SharePoint site URL"
  type        = string
  sensitive   = true
}

# License and Keygen Variables
variable "keygen_public_key" {
  description = "The public key for Keygen license validation"
  type        = string
  sensitive   = true
}

variable "license_key" {
  description = "The application license key"
  type        = string
  sensitive   = true
}