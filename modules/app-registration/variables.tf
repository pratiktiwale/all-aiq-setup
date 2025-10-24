

variable "service_type" {
  description = "The service type (e.g., app, appreg)"
  type        = string
  default     = "app"
}


variable "project_unique_id" {
  description = "Project unique identifier used in naming"
  type        = string
}


variable "description" {
  description = "Description for the app registration"
  type        = string
  default     = ""
}

variable "spa_redirect_uris" {
  description = "List of redirect URIs for Single Page Application"
  type        = list(string)
  default = [
    "http://localhost:4200/platform/home",
    "http://localhost:8000/callback"
  ]
}

variable "backend_web_app_url" {
  description = "Backend Web App Service URL (to be added to redirect URIs)"
  type        = string
  default     = ""
}

variable "frontend_web_app_url" {
  description = "Frontend Web App Service URL (to be added to redirect URIs)"
  type        = string
  default     = ""
}

variable "app_scope_id" {
  description = "UUID for the app scope (must be unique)"
  type        = string
  default     = "12345678-1234-1234-1234-123456789012"  # You should generate a unique UUID
}

variable "client_secret_end_date" {
  description = "The end date until which the password is valid, formatted as an RFC3339 date string"
  type        = string
  default     = "2025-12-31T23:59:59Z"
}