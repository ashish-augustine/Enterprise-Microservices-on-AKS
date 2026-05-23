# Azure Active Directory Managed Identity for the AKS Control Plane
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-aks-control-plane-prod"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
}

# Core Production-Grade AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-enterprise-prod"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "aks-enterprise-cluster"
  kubernetes_version  = "1.30" # Standard enterprise-grade stable release

  # Zero-Trust Identity Configurations
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # System Assigned Identity for Cluster Management
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  # Production Network Profile using Azure CNI
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure" # Enforces Zero-Trust pod-level isolation network policies
    load_balancer_sku = "standard"
  }

  # Dedicated System Node Pool (Houses Core Addons & ArgoCD)
  default_node_pool {
    name           = "systempool"
    vm_size        = "Standard_D2s_v5" # Balanced compute for Free Trial quotas
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
    node_count     = 2                 # High availability baseline
    os_sku         = "Mariner"         # Microsoft's secure, minimal container-optimized OS
    
    # Best Practice: Label system nodes to prevent application scheduling conflicts
    node_labels = {
      "environment" = "production"
      "tier"        = "system"
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count # Allows autoscaler to manage nodes without state drift
    ]
  }
}

# Outputs needed for configuring the Kubernetes provider and workload identity later
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}
