#providers.tf

terraform {
  required_version = ">=1.1.9"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.6"
    }
  }
}

provider "azurerm" {
  features {}
}