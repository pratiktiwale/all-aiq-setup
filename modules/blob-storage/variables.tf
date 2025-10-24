variable "resource_group_name" {
  description = "Resource group to create the storage account in"
  type        = string
}

variable "location" {
  description = "Azure region for the storage account"
  type        = string
}

variable "env_code" {
  description = "Environment code used in naming"
  type        = string
}

variable "service_type" {
  description = "Service type string used in naming (e.g., 'blob')"
  type        = string
  default     = "blob"
}

variable "resource_number" {
  description = "Number suffix for resource name"
  type        = string
  default     = "01"
}

variable "account_tier" {
  description = "Storage account tier (Standard/Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication type (LRS/GRS/RAGRS/etc.)"
  type        = string
  default     = "GRS"
}

variable "is_hns_enabled" {
  description = "Enable hierarchical namespace (for ADLS Gen2)"
  type        = bool
  default     = false
}

variable "project_unique_id" {
  description = "A unique project ID to ensure global uniqueness for the App Service name."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
  default     = {}
}
