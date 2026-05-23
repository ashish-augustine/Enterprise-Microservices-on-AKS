resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-aks-control-plane-prod"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-enterprise-prod"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aks-enterprise-cluster"
  kubernetes_version  = "1.31"
  
  # Production Best Practice: SLA-backed tier with LTS support
  sku_tier            = "Premium"
  support_plan        = "AKSLongTermSupport"

  image_cleaner_enabled        = false
  image_cleaner_interval_hours = 48
  
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  role_based_access_control_enabled = true
  run_command_enabled               = true
  
  private_cluster_enabled             = false
  private_cluster_public_fqdn_enabled = false

  default_node_pool {
    name                = "systempool"
    node_count          = 2
    vm_size             = "Standard_D2s_v3"
    os_disk_type        = "Managed"
    os_sku              = "Mariner"
    scale_down_mode     = "Delete"
    type                = "VirtualMachineScaleSets"
    ultra_ssd_enabled   = false
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    
    node_labels = {
      "environment" = "production"
      "tier"        = "system"
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }
}