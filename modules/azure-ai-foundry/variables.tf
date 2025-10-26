# modules/azure-ai-foundry/variables.tf

variable "location" {
  description = "The Azure region for the AI Foundry resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy AI Foundry resources into"
  type        = string
}

variable "resource_use" {
  description = "The resource use identifier (e.g., ai, ml)"
  type        = string
  default     = "ai"
}

variable "project_unique_id" {
  description = "The unique project identifier"
  type        = string
}





variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

#----------------------------------------------------------------------------------------------------------------
# Variables for GPT-4o Deployment
#----------------------------------------------------------------------------------------------------------------
variable "gpt4_deployment_name" {
  description = "The name of the GPT-4o deployment."
  type        = string
  default     = "gpt-4o"
}

variable "gpt4_model_name" {
  description = "The name of the GPT-4o model."
  type        = string
  default     = "gpt-4o"
}

variable "gpt4_model_version" {
  description = "The version of the GPT-4o model."
  type        = string
  default     = "2024-08-06"
}

variable "gpt4_sku_name" {
  description = "The SKU name for the GPT-4o deployment (Standard or GlobalStandard)."
  type        = string
  default     = "GlobalStandard"
}

variable "gpt4_capacity" {
  description = "The capacity for the GPT-4o deployment."
  type        = number
  default     = 10
}

#----------------------------------------------------------------------------------------------------------------
# Variables for Embedding Deployment
#----------------------------------------------------------------------------------------------------------------
variable "embedding_deployment_name" {
  description = "The name of the embedding deployment."
  type        = string
  default     = "text-embedding-ada-002"
}

variable "embedding_model_name" {
  description = "The name of the embedding model."
  type        = string
  default     = "text-embedding-ada-002"
}

variable "embedding_model_version" {
  description = "The version of the embedding model."
  type        = string
  default     = "2"
}

variable "embedding_sku_name" {
  description = "The SKU name for the embedding deployment (Standard or GlobalStandard)."
  type        = string
  default     = "GlobalStandard"
}

variable "embedding_capacity" {
  description = "The capacity for the embedding deployment."
  type        = number
  default     = 1
}