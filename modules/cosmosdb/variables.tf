variable "resource_group_name" {
  description = "The name of the resource group where Cosmos DB will reside."
  type        = string
}

variable "location" {
  description = "The Azure region for the Cosmos DB account."
  type        = string
}

# --- Naming Convention Variables (Used in main.tf locals block) ---

variable "env_code" {
  description = "The environment code (e.g., dev, qa) for the name."
  type        = string
}

variable "service_type" {
  description = "The service type (e.g., cosmosdb, blob)."
  type        = string
  default     = "cosmosdb"
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

variable "database_throughput" {
  description = "The throughput (RU/s) to apply to the SQL database for shared capacity."
  type        = number
  default     = 1000 # Example shared throughput value
}

# --- Resource Configuration Variables ---
variable "env" {
  description = "The name of the SQL API database to create."
  type        = string
  default     = "dev"
}

# Fixed list of container configurations
variable "container_definitions" {
  description = "A fixed list of container configurations that must be created."
  type = list(object({
    name               = string
   
  }))

  # These are your fixed container names and configurations
  default = [
    {
      name               = "article_versions"
          
    },
    {
      name               = "articles"
      
    },
    {
      name               = "conversations"
      
    },
     {
      name               = "feedbacks"
      
    },
    {
      name               = "notifications"
      
    },
     {
      name               = "searchindex-delta"
      
    },
     {
      name               = "starter_queries"
      
    },
    {
      name               = "system_configs"
      
    },
    {
      name               = "user_groups"
      
    }
    
  ]
}

variable "tags" {
  description = "A map of tags to assign to the Cosmos DB account."
  type        = map(string)
  default     = {} # Default empty map, allowing root module to provide tags
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the User-Assigned Managed Identity for data plane RBAC"
  type        = string
}