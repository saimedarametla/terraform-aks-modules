terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.50"
    }
  }
  required_version = ">= 1.3"
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name                 = "system"
    vm_size              = var.default_node_pool.vm_size
    node_count           = var.default_node_pool.node_count
    min_count            = var.default_node_pool.min_count
    max_count            = var.default_node_pool.max_count
    enable_auto_scaling  = true
    availability_zones   = lookup(var.default_node_pool, "availability_zones", ["1", "2", "3"])
    vnet_subnet_id       = var.subnet_id
    only_critical_addons_enabled = true  # system pool runs only system pods

    upgrade_settings {
      max_surge = "33%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [1, 2, 3]
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,  # managed by autoscaler
      kubernetes_version,               # managed via upgrade pipeline
    ]
  }
}
