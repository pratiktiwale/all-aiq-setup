terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "58ace139-af0e-4d71-83b4-8dece6cf8331"
}


