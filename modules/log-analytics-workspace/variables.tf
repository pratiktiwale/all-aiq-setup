
#----------------------------------------------------------------------------------------------------------------
# Core Infrastructure Variables
#----------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group where the Log Analytics Workspace will be created"
  type        = string
}

variable "location" {
  description = "The Azure region where the Log Analytics Workspace will be deployed"
  type        = string
}

#----------------------------------------------------------------------------------------------------------------
# Naming Convention Variables
#----------------------------------------------------------------------------------------------------------------

variable "env_code" {
  description = "The environment code (e.g., 'dev', 'prod', 'staging')"
  type        = string
}

variable "service_type" {
  description = "The service type identifier for naming convention"
  type        = string
  default     = "law"
}

variable "project_unique_id" {
  description = "A unique identifier for the project to ensure global uniqueness"
  type        = string
}

variable "resource_number" {
  description = "The resource number suffix (e.g., '01', '02')"
  type        = string
  default     = "01"
}

#----------------------------------------------------------------------------------------------------------------
# Log Analytics Workspace Configuration
#----------------------------------------------------------------------------------------------------------------

variable "sku" {
  description = "The SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018"
  type        = string
  default     = "PerGB2018"
  
  validation {
    condition = contains([
      "Free", "PerNode", "Premium", "Standard", 
      "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"
    ], var.sku)
    error_message = "SKU must be one of: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, or PerGB2018."
  }
}

variable "retention_in_days" {
  description = "The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730"
  type        = number
  default     = 30
  
  validation {
    condition     = var.retention_in_days == 7 || (var.retention_in_days >= 30 && var.retention_in_days <= 730)
    error_message = "Retention must be 7 days (Free tier) or between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "The daily quota for ingestion in GB. Set to -1 for unlimited"
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Should the Log Analytics Workspace support ingestion over the Public Internet?"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Should the Log Analytics Workspace support querying over the Public Internet?"
  type        = bool
  default     = true
}

#----------------------------------------------------------------------------------------------------------------
# Solution Configuration
#----------------------------------------------------------------------------------------------------------------

variable "enable_container_insights" {
  description = "Enable Container Insights solution for monitoring containers"
  type        = bool
  default     = false
}

variable "enable_security_center" {
  description = "Enable Security Center solution for security monitoring"
  type        = bool
  default     = false
}

variable "enable_azure_activity" {
  description = "Enable Azure Activity solution for activity log monitoring"
  type        = bool
  default     = true
}

#----------------------------------------------------------------------------------------------------------------
# Tags
#----------------------------------------------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}