output "argocd_release_name" {
  description = "Helm release name for Argo CD."
  value       = helm_release.argocd.name
}

output "argocd_namespace" {
  description = "Namespace containing Argo CD."
  value       = helm_release.argocd.namespace
}