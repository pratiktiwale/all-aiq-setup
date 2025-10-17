output "redis_host" {
  value = azurerm_redis_cache.main.hostname
}

output "redis_primary_key" {
  value     = azurerm_redis_cache.main.primary_access_key
  sensitive = true
}


output "id" {
  value = azurerm_redis_cache.main.id
}

output "name" {
  value = azurerm_redis_cache.main.name
}
