variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_number" {
  type = string
  default = "01"
}

variable "sku_name" {
  type = string
  default = "Standard"
}

variable "family" {
  description = "Redis family (C for current provider versions)"
  type = string
  default = "C"
}

variable "capacity" {
  description = "Instance size (e.g., 1, 2, 3)"
  type = number
  default = 1
}

variable "enable_non_ssl_port" {
  type = bool
  default = false
}

variable "minimum_tls_version" {
  type = string
  default = "1.2"
}

variable "redis_configuration" {
  type = map(string)
  default = {}
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the User-Assigned Managed Identity for data access policy"
  type        = string
}
