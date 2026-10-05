variable "kubeconfig_path" {
  description = "Path to the kubeconfig for the AKS cluster."
  type        = string
  default     = "~/.kube/config"
}