# modules/cosmosdb/main.tf
#--------------------------------------------------------------------------------------------------------------------------------
# 1.Locals for Naming Convention
#--------------------------------------------------------------------------------------------------------------------------------

locals {
  # Construct the base name: aiq-{env}-cosmos-{number} (per documentation)
  base_name = format(
    "aiq-%s-cosmos-%s",
    var.env_code,
    var.resource_number
  )
  # Cosmos DB account name must be globally unique and lowercase
  cosmos_account_name = lower(local.base_name)
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
  name                = "aiq-${var.env_code}-db-1"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  
  # Conditional throughput configuration based on use_autoscale
  throughput = var.use_autoscale ? null : var.database_throughput
  
  dynamic "autoscale_settings" {
    for_each = var.use_autoscale ? [1] : []
    content {
      max_throughput = var.database_max_throughput
    }
  }
}

#--------------------------------------------------------------------------------------------------------------------------------
# 3. Cosmos DB Containers (Using count for fixed list)
#--------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_cosmosdb_sql_container" "containers" {
  count               = length(var.container_definitions)
  
  name                = var.container_definitions[count.index].name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  
  partition_key_paths = ["/id"]
  
}

#--------------------------------------------------------------------------------------------------------------------------------
# 4. Container-Level Data Plane RBAC Role Assignments for Managed Identity (Per Documentation)
#--------------------------------------------------------------------------------------------------------------------------------

# Get current subscription ID for role definition
data "azurerm_client_config" "current" {}

# Container-level RBAC assignments for each container (as per documentation requirements)
resource "azurerm_cosmosdb_sql_role_assignment" "container_data_contributor" {
  count               = length(var.container_definitions)
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  
  # Built-in Data Contributor role definition ID
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.main.name}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  
  principal_id = var.managed_identity_principal_id
  
  # Container-level scope: /dbs/{database_name}/colls/{container_name}
  scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.DocumentDB/databaseAccounts/${azurerm_cosmosdb_account.main.name}/dbs/${azurerm_cosmosdb_sql_database.main.name}/colls/${var.container_definitions[count.index].name}"
  
  depends_on = [
    azurerm_cosmosdb_sql_container.containers,
    azurerm_cosmosdb_sql_database.main
  ]
}