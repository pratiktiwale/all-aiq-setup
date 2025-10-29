variable "resource_group_name" {
  description = "The name of the resource group to deploy the function app into"
  type        = string
}

variable "location" {
  description = "The Azure region for the Function App"
  type        = string
}

variable "env_code" {
  description = "The environment code (e.g., dev, qa) for the name"
  type        = string
}

variable "service_type" {
  description = "The service type (e.g., function, func)"
  type        = string
  default     = "function"
}

variable "project_unique_id" {
  description = "Project unique identifier used in naming"
  type        = string
}

variable "resource_number" {
  description = "The number suffix (e.g., 01, 02)"
  type        = string
  default     = "01"
}

variable "maximum_instance_count" {
  description = "Maximum number of instances for the function app"
  type        = number
  default     = 100
}

variable "app_settings" {
  description = "A map of application settings (environment variables) for the Function App"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_app_insights" {
  description = "Enable creation and wiring of Application Insights for this function app"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to link Application Insights to (optional)"
  type        = string
  default     = null
}