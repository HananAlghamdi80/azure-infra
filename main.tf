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
  subscription_id = "80646857-9142-494b-90c5-32fea6acbc41"
  tenant_id       = "84f58ce9-43c8-4932-b908-591a8a3007d3"
  use_cli         = true
}

#############################################
# Resource Group
#############################################
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
