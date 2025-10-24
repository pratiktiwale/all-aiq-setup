variable "resource_group_name" {
  description = "The name of the resource group to deploy the managed identity into"
  type        = string
}

variable "location" {
  description = "The Azure region for the Managed Identity"
  type        = string
}


variable "service_type" {
  description = "The service type (e.g., identity, mi)"
  type        = string
  default     = "mi"
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

variable "tags" {
  description = "A map of tags to assign to the managed identity"
  type        = map(string)
  default     = {}
}