variable "resource_group_name" {
  description = "The name of the resource group to deploy the plan into."
  type        = string
}

variable "location" {
  description = "The Azure region for the App Service Plan."
  type        = string
}

# Naming Convention Variables

variable "resource_use" {
  description = "The usage of the resource (e.g., common, shared)."
  type        = string
  default     = "shared"
}

variable "resource_number" {
  description = "The number suffix (e.g., 01, 02)."
  type        = string
  default     = "01"
}

variable "sku_name" {
  description = "The SKU for the App Service Plan (e.g., B3, S1, P1v2)."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}