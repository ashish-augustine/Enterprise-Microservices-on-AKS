# 1. Create a dedicated Azure Identity for our Application Workloads
resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = "id-aks-store-workload-prod"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
}

# 2. Federate the Azure Identity with a Kubernetes Service Account
resource "azurerm_federated_identity_credential" "workload_federation" {
  name                = "fic-aks-store-workload-prod"
  resource_group_name = azurerm_resource_group.aks_rg.name
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  audience            = ["api://AzureADTokenExchange"]
  
  # This dynamically references the OIDC URL your cluster generated
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  
  # This string maps exactly to the Kubernetes Namespace and Service Account we will use later
  subject             = "system:serviceaccount:aks-store-demo:workload-sa"
}

# 3. Output the Client ID for our GitOps configuration later
output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload_identity.client_id
}
