terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.74.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = ""
  tenant_id       = ""
  use_cli         = true
}

#############################################
# Resource Group
#############################################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
