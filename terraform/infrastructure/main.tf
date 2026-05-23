resource "azurerm_resource_group" "aks_rg" {
  name     = "rg-aks-enterprise-prod"
  location = "eastus"
}
