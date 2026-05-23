# Enterprise VNet for Network Isolation
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks-enterprise"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.1.0.0/16"]
}

# Dedicated Subnet for AKS Nodes and Pods
resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks-nodes"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.0.0/22"] 
}
