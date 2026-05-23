# terraform/bootstrap/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Resource Group for State
resource "azurerm_resource_group" "tfstate" {
  name     = "rg-tfstate-ops-prod"
  location = "eastus" # Safest region for free trial capacity
}

# 2. Random ID to ensure Storage Account name is globally unique
resource "random_id" "storage_suffix" {
  byte_length = 3
}

# 3. Secure Storage Account
resource "azurerm_storage_account" "tfstate" {
  name                            = "sttfstateaks${random_id.storage_suffix.hex}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS" # Production best practice: Zone Redundancy
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false # Zero-Trust: Block public blob access

  blob_properties {
    versioning_enabled = true # Enables rollback if state gets corrupted
  }
}

# 4. Storage Container for the state file
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate-core"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# 5. Output the names so we can use them in the next step
output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
  value = azurerm_storage_container.tfstate.name
}