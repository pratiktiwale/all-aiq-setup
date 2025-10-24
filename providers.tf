terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116.0" # Last stable version with reliable classic Application Insights support
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


