# modules/ai_search/variables.tf


variable "resource_group_name" {
  description = "Resource group to create the storage account in"
  type        = string
}

variable "location" {
  description = "Azure region for the storage account"
  type        = string
}


variable "service_type" {
  description = "Service type string used in naming (e.g., 'search')"
  type        = string
  default     = "search"
}

variable "resource_number" {
  description = "Number suffix for resource name"
  type        = string
  default     = "01"
}

variable "project_unique_id" {
  description = "A unique project ID to ensure global uniqueness for the App Service name."
  type        = string
}

variable "sku" {
  description = "The SKU of the Azure Search service. For production workloads, consider 'standard' or higher."
  type        = string
  default     = "standard"
  
  validation {
    condition = contains([
      "free", "basic", "standard", "standard2", 
      "standard3", "storage_optimized_l1", "storage_optimized_l2"
    ], var.sku)
    error_message = "SKU must be one of: free, basic, standard, standard2, standard3, storage_optimized_l1, storage_optimized_l2."
  }
}

variable "replica_count" {
  description = "The number of replicas for the Azure Search service. For high availability, use 2 or more."
  type        = number
  default     = 2
  
  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 12
    error_message = "Replica count must be between 1 and 12."
  }
}

variable "partition_count" {
  description = "The number of partitions for the Azure Search service"
  type        = number
  default     = 1
  
  validation {
    condition     = var.partition_count >= 1 && var.partition_count <= 12
    error_message = "Partition count must be between 1 and 12."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Index Configuration Variables
variable "index_name" {
  description = "Name of the search index"
  type        = string
  default     = "aiq-index"
}

variable "create_index" {
  description = "Whether to create the search index"
  type        = bool
  default     = true
}

# Azure OpenAI Configuration for Vectorizer
variable "openai_resource_uri" {
  description = "Azure OpenAI resource URI for vectorizer"
  type        = string
}

variable "openai_deployment_id" {
  description = "Azure OpenAI deployment ID for text embeddings"
  type        = string
  default     = "text-embedding-ada-002"
}

variable "openai_model_name" {
  description = "Azure OpenAI model name for embeddings"
  type        = string
  default     = "text-embedding-ada-002"
}

# Vector Search Configuration
variable "vector_dimensions" {
  description = "Dimensions for the embedding vector field"
  type        = number
  default     = 1536
}

variable "vector_search_algorithm_name" {
  description = "Name for the vector search algorithm"
  type        = string
  default     = "hnsw-1"
}

variable "vector_search_profile_name" {
  description = "Name for the vector search profile"
  type        = string
  default     = "vector-profile-hnsw-1"
}

variable "hnsw_parameters" {
  description = "HNSW algorithm parameters"
  type = object({
    metric         = string
    m             = number
    efConstruction = number
    efSearch      = number
  })
  default = {
    metric         = "cosine"
    m             = 4
    efConstruction = 200
    efSearch      = 100
  }
}

# Semantic Search Configuration
variable "semantic_config_name" {
  description = "Name for the semantic search configuration"
  type        = string
  default     = "default-semantic-config"
}

variable "title_field_name" {
  description = "Field name to use as title in semantic search"
  type        = string
  default     = "title"
}

variable "content_field_names" {
  description = "Field names to use as content in semantic search"
  type        = list(string)
  default     = ["content"]
}

variable "keywords_field_names" {
  description = "Field names to use as keywords in semantic search"
  type        = list(string)
  default     = ["keywords"]
}


