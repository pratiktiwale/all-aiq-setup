variable "resource_group_name" {
  description = "The name of the resource group to deploy the app into."
  type        = string
}

variable "location" {
  description = "The Azure region for the App Service."
  type        = string
}

variable "service_type" {
  description = "The service type (e.g., webapp, functionapp)."
  type        = string
}

variable "resource_use" {
  description = "The usage of the resource (e.g., be, fe, indexer)."
  type        = string
}

variable "resource_number" {
  description = "The number suffix (e.g., 01, 02)."
  type        = string
  default     = "01"
}

variable "project_unique_id" {
  description = "A unique project ID to ensure global uniqueness for the App Service name."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

# Azure OpenAI Specific Variables for Embedding Deployment

variable "embedding_deployment_name" {
  description = "The name of the embedding deployment."
  type        = string
}

variable "embedding_model_name" {
  description = "The name of the embedding model."
  type        = string
}

variable "embedding_model_version" {
  description = "The version of the embedding model."
  type        = string
}

variable "embedding_sku_name" {
  description = "The SKU name for the embedding deployment (Standard or GlobalStandard)."
  type        = string
  default     = "Standard"
}

variable "embedding_capacity" {
  description = "The capacity for the embedding deployment."
  type        = number
  default     = 1
}

variable "embedding_rate_limit_count" {
  description = "The rate limit count for the embedding deployment."
  type        = number
  default     = 1000
}

variable "embedding_rate_limit_renewal_period" {
  description = "The rate limit renewal period for the embedding deployment."
  type        = string
  default     = "60s"
}
