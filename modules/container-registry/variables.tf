variable "resource_group_name" {
  description = "The name of the resource group where ACR will reside."
  type        = string
}

variable "location" {
  description = "The Azure region for the ACR."
  type        = string
}

# Naming Convention Variables (aiq-{env}-acr-{resource-use}-{number})

variable "resource_number" {
  description = "The number suffix (e.g., 01, 02)."
  type        = string
  default     = "01"
}

variable "sku" {
  description = "The SKU for the Container Registry (e.g., Basic, Standard, Premium)."
  type        = string
  default     = "Premium"
}

variable "backend_repo_name" {
  description = "The name of the repository for the backend image (e.g., 'backend-api')."
  type        = string
  default     = "backend-api"
}

variable "frontend_repo_name" {
  description = "The name of the repository for the frontend image (e.g., 'frontend-app')."
  type        = string
  default     = "frontend-app"
}

variable "tags" {
  description = "A map of tags to assign to the ACR resource."
  type        = map(string)
  default     = {}
}

variable "project_unique_id" {
  description = "A unique project ID to ensure global uniqueness for the App Service name."
  type        = string
}