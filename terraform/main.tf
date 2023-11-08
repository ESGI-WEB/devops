# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Main resource group
resource "azurerm_resource_group" "rg_main" {
  name     = var.resource_group
  location = var.location

  tags = {
    environment = "DevOps Project"
  }
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                     = "ContainerRegistry"
  resource_group_name      = azurerm_resource_group.rg_main.name
  location                 = azurerm_resource_group.rg_main.location
  sku                      = "Standard"
  admin_enabled            = true

  tags = {
    environment = "DevOps Project"
  }
}

# Azure Kubernetes Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "AKSCluster"
  location            = azurerm_resource_group.rg_main.location
  resource_group_name = azurerm_resource_group.rg_main.name
  dns_prefix          = "aksdns"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  tags = {
    environment = "DevOps Project"
  }
}

# Public IP in the Kubernetes resource group
resource "azurerm_public_ip" "public_ip" {
  name                = "PublicIP"
  location            = var.location
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  allocation_method   = "Dynamic"
}