terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.50"
    }
  }
  # Uncomment for remote state
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate"
  #   storage_account_name = "sttfstate001"
  #   container_name       = "tfstate"
  #   key                  = "aks-prod.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

locals {
  cluster_name = "aks-${var.environment}-001"
  common_tags = {
    environment = var.environment
    managed_by  = "terraform"
    owner       = "platform-team"
  }
}

module "networking" {
  source              = "../../modules/networking"
  cluster_name        = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  vnet_address_space  = var.vnet_address_space
  aks_subnet_prefix   = var.aks_subnet_prefix
  tags                = local.common_tags
}

module "aks_cluster" {
  source              = "../../modules/aks-cluster"
  cluster_name        = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.kubernetes_version
  subnet_id           = module.networking.aks_subnet_id

  default_node_pool = {
    vm_size            = var.system_node_vm_size
    node_count         = 3
    min_count          = var.environment == "prod" ? 3 : 1
    max_count          = var.environment == "prod" ? 9 : 3
    availability_zones = ["1", "2", "3"]
  }

  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = local.common_tags
}

module "app_node_pool" {
  source                = "../../modules/node-pool"
  node_pool_name        = "apppool"
  kubernetes_cluster_id = module.aks_cluster.cluster_id
  vm_size               = var.app_node_vm_size
  min_count             = var.environment == "prod" ? 2 : 1
  max_count             = var.environment == "prod" ? 10 : 4
  availability_zones    = ["1", "2", "3"]
  subnet_id             = module.networking.aks_subnet_id
  node_taints           = ["workload=app:NoSchedule"]
  node_labels           = { "workload" = "app" }
  tags                  = local.common_tags
}

module "keyvault" {
  source              = "../../modules/keyvault-integration"
  cluster_name        = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  kubelet_identity_id = module.aks_cluster.kubelet_identity_object_id
  tags                = local.common_tags
}
