output "resource_group_name" {
  description = "Resource group containing the production AKS cluster."
  value       = azurerm_resource_group.production.name
}

output "cluster_name" {
  description = "Name of the production AKS cluster."
  value       = azurerm_kubernetes_cluster.production.name
}

output "location" {
  description = "Azure region containing the production cluster."
  value       = azurerm_kubernetes_cluster.production.location
}