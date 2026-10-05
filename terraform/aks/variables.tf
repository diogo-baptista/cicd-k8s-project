variable "name" {
  description = "Short prefix used for the production Azure resource names."
  type        = string
  default     = "cicd-api-prod"
}

variable "location" {
  description = "Azure region in which to create the production cluster."
  type        = string
  default     = "eastus"
}

variable "node_count" {
  description = "Number of AKS nodes."
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "Azure VM size for the AKS node pool."
  type        = string
  default     = "Standard_B2s"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key installed on the Linux node pool."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "subscription_id" {
  description = "Azure subscription ID. Set ARM_SUBSCRIPTION_ID instead to keep it out of tfvars."
  type        = string
  default     = null
}