variable "resource_group_name" {
  description = "The name of the resource group to deploy the app into."
  type        = string
}

variable "location" {
  description = "The Azure region for the App Service."
  type        = string
}

variable "env_code" {
  description = "The environment code (e.g., dev, qa) for the name."
  type        = string
}

variable "service_type" {
  description = "The service type (e.g., webapp, functionapp)."
  type        = string
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

variable "service_plan_id" {
  description = "The ID of the existing App Service Plan to attach the Web App to."
  type        = string
}

variable "app_settings" {
  description = "A map of application settings (environment variables)."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}

variable "project_unique_id" {
  description = "A unique project ID to ensure global uniqueness for the App Service name."
  type        = string
}

# Container Configuration Inputs (from ACR module outputs)

variable "docker_image_name" {
  description = "The image name and tag (e.g., 'backend-api:v1.0')."
  type        = string
}

variable "docker_registry_url" {
  description = "The login server URL (e.g., 'myacr.azurecr.io')."
  type        = string
}
variable "docker_username" {
  description = "The ACR Admin Username."
  type        = string
  sensitive   = true
}
variable "docker_password" {
  description = "The ACR Admin Password."
  type        = string
  sensitive   = true
}
variable "docker_startup_command" {
  description = "The command to run when the container starts (e.g., gunicorn...)."
  type        = string
  default     = null
}

variable "image_tag" {
  description = "The specific tag for the Docker image (e.g., 'v1.0' or 'latest')."
  type        = string
  default     = "v1.0"
}

variable "image_name" {
  description = "The specific tag for the Docker image (e.g., 'v1.0' or 'latest')."
  type        = string
 
}

variable "acr_login_server" {
  description = "The login server URL of the Azure Container Registry (e.g., 'myacr.azurecr.io')."
  type        = string
  # No default needed, as it should be passed from the root module using module.acr.login_server
}

variable "enable_app_insights" {
  description = "Enable creation and wiring of Application Insights for this web app."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace to link Application Insights to (optional)"
  type        = string
  default     = null
}

