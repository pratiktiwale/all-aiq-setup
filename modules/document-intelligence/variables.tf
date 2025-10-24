variable "location" {
  description = "The Azure region for the Document Intelligence service"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy the Document Intelligence service into"
  type        = string
}

variable "env_code" {
  description = "The environment code (e.g., dev, qa) for the name"
  type        = string
}

variable "project_unique_id" {
  description = "A unique project identifier to ensure global uniqueness"
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Document Intelligence service"
  type        = string
  default     = "S0"  # Standard pricing tier
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}