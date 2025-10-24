# soft-delete-config.tf
# Global configuration for soft-delete behavior across all resources

variable "enable_soft_delete_protection" {
  description = "Enable soft delete protection for resources that support it"
  type        = bool
  default     = false # Set to false for immediate permanent deletion
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted resources (minimum: 1-7 depending on service)"
  type        = number
  default     = 1 # Minimum retention for quick cleanup
}

variable "enable_purge_protection" {
  description = "Enable purge protection to prevent immediate purging"
  type        = bool
  default     = false # Set to false to allow immediate purging
}

# Local values for consistent soft-delete configuration
locals {
  soft_delete_config = {
    key_vault = {
      soft_delete_retention_days = var.enable_soft_delete_protection ? var.soft_delete_retention_days : 7 # Key Vault minimum is 7 days
      purge_protection_enabled   = var.enable_purge_protection
    }

    storage_account = {
      blob_delete_retention_days      = var.enable_soft_delete_protection ? var.soft_delete_retention_days : 1
      container_delete_retention_days = var.enable_soft_delete_protection ? var.soft_delete_retention_days : 1
    }

    cognitive_services = {
      # Note: Cognitive Services (OpenAI) soft-delete cannot be disabled
      # Must be purged manually or wait for automatic purge (48 hours)
      auto_purge_enabled = !var.enable_soft_delete_protection
    }
  }
}