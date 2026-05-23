terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
  
  # Enterprise Best Practice: Cloud-hosted state file
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-ops-prod"
    storage_account_name = "sttfstateakse7b49e"
    container_name       = "tfstate-core"
    key                  = "core-infra.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
