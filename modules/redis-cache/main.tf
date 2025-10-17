#--------------------------------------------------------------------------------------------------------------------------------
# local variables and resources for Redis Cache
#--------------------------------------------------------------------------------------------------------------------------------

locals {
  # Name: aiq-common-redis-{resource_number}
  base_name = format("aiq-common-redis-%s", var.resource_number)

  redis_name = lower(local.base_name)
}

#--------------------------------------------------------------------------------------------------------------------------------
# Redis Cache Resources
#--------------------------------------------------------------------------------------------------------------------------------

resource "azurerm_redis_cache" "main" {
  name                = local.redis_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.sku_name
  capacity = var.capacity
  family   = var.family

  minimum_tls_version = var.minimum_tls_version

  tags = var.tags
}



