terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

# The smallest useful setup: a VNet and a cluster. Use ../production-cluster for the full stack.
module "networking" {
  source              = "../../modules/networking"
  cluster_name        = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "aks_cluster" {
  source              = "../../modules/aks-cluster"
  cluster_name        = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.aks_subnet_id
  sku_tier            = "Free"
}
