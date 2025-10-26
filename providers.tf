terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0" # Latest version with AIServices support
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}


