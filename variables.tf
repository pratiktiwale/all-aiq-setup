variable "resource_group_name" {
  description = "The name of the Azure Resource Group to create (e.g., aiq-rg-common-eastus-01)."
  type        = string
  default     = "aiq-internal-iaac-rg"
}

variable "location" {
  description = "The Azure region for deployment."
  type        = string
  default     = "Central India"
}

variable "environment" {
  description = "The environment code for the naming convention (e.g., 'dev', 'qa', 'iaac-dev')."
  type        = string
  default     = "dev"
}

variable "env" {
  description = "The environment code for the naming convention (e.g., 'dev', 'qa', 'iaac-dev')."
  type        = string
  default     = "Dev" # Capitalized for tag consistency
}


variable "project_unique_id" {
  description = "A unique, short identifier (e.g., a few random letters/numbers) to guarantee globally unique Web App names."
  type        = string
  default     = "lrm" # CHANGE THIS DEFAULT TO SOMETHING TRULY UNIQUE
}

variable "hosting_mode" {
  description = "The hosting mode for Azure AI Search (e.g., 'default', 'high-density')"
  type        = string
  default     = "default"
}