# modules/cosmosdb/main.tf
#--------------------------------------------------------------------------------------------------------------------------------
# 1.Locals for Naming Convention
#--------------------------------------------------------------------------------------------------------------------------------

locals {
  # Construct the base name: aiq-{env}-{service-type}-{resource-use}-{number}
  base_name = format(
    "aiq-%s-%s-%s",
    var.env_code,
    var.service_type,
    #var.resource_use,
    var.resource_number
  )
  # Cosmos DB account name must be globally unique and lowercase
  cosmos_account_name = lower(replace(local.base_name, "-", "")) # Azure limitation: CosmosDB names cannot have hyphens
}

#--------------------------------------------------------------------------------------------------------------------------------
# 2.Cosmos DB Account
#--------------------------------------------------------------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "main" {
  name                = local.cosmos_account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB" # SQL API
  tags                = var.tags

  consistency_policy {
    consistency_level = "Session" 
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# 3.Cosmos DB SQL Database and Containers
#--------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "aiq-${var.env}-db-01"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = var.database_throughput
}

#--------------------------------------------------------------------------------------------------------------------------------
# 3. Cosmos DB Containers (Using count for fixed list)
#--------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_container" "containers" {
  count               = length(var.container_definitions)
  
  # REMOVED: container_config = var.container_definitions[count.index] 
  # ACCESSING VALUES DIRECTLY using var.container_definitions[count.index].<attribute>
  
  name                = var.container_definitions[count.index].name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  
  partition_key_paths = ["/id"]
  
}