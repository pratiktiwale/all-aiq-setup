variable "resource_group_name" {
  description = "Resource group to create the key vault in"
  type        = string
}

variable "location" {
  description = "Azure region for the key vault"
  type        = string
}

variable "service_type" {
  description = "Service type string used in naming (e.g., 'kv')"
  type        = string
  default     = "kv"
}

variable "project_unique_id" {
  description = "Project unique identifier used in naming"
  type        = string
}

variable "resource_number" {
  description = "Number suffix for resource name"
  type        = string
  default     = "01"
}

variable "tags" {
  description = "A mapping of tags to assign to the key vault"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of secrets to create in the Key Vault (key = secret name, value = secret value)"
  type        = map(string)
  default     = {}
}