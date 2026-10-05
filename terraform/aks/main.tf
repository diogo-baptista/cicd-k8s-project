terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

moved {
  from = azurerm_resource_group.dev
  to   = azurerm_resource_group.production
}

moved {
  from = azurerm_kubernetes_cluster.dev
  to   = azurerm_kubernetes_cluster.production
}

resource "azurerm_resource_group" "production" {
  name     = "${var.name}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_kubernetes_cluster" "production" {
  name                = "${var.name}-aks"
  location            = azurerm_resource_group.production.location
  resource_group_name = azurerm_resource_group.production.name
  dns_prefix          = "${var.name}-dns"

  default_node_pool {
    name            = "system"
    node_count      = var.node_count
    vm_size         = var.node_vm_size
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
  }

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = file(pathexpand(var.ssh_public_key_path))
    }
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  tags = local.tags
}

locals {
  tags = {
    environment = "production"
    managed_by  = "terraform"
    project     = "cicd-k8s-project"
  }
}