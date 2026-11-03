terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
  required_version = ">= 1.3"
}

resource "azurerm_kubernetes_cluster" "this" {
  # Deliberate Checkov skips (see "Security notes" in the README):
  #checkov:skip=CKV_AZURE_115:Private cluster is opt-in via private_cluster_enabled
  #checkov:skip=CKV_AZURE_6:Authorized IP ranges are opt-in via api_server_authorized_ip_ranges (not supported on private clusters)
  #checkov:skip=CKV_AZURE_171:Upgrade channel is opt-in via automatic_channel_upgrade; upgrades are otherwise managed by your pipeline
  #checkov:skip=CKV_AZURE_117:Disk encryption sets need a customer-managed key, which is out of scope for this module
  #checkov:skip=CKV_AZURE_227:Host encryption needs the EncryptionAtHost subscription feature registered
  #checkov:skip=CKV_AZURE_226:Ephemeral OS disks depend on the VM SKU cache size, so they are not forced on the system pool
  #checkov:skip=CKV_AZURE_168:Azure CNI reserves one IP per pod, so 50+ pods per node needs a larger subnet than the default /24
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  private_cluster_enabled   = var.private_cluster_enabled
  sku_tier                  = var.sku_tier
  azure_policy_enabled      = true
  local_account_disabled    = true
  automatic_channel_upgrade = var.automatic_channel_upgrade

  default_node_pool {
    name                         = "system"
    vm_size                      = var.default_node_pool.vm_size
    node_count                   = var.default_node_pool.node_count
    min_count                    = var.default_node_pool.min_count
    max_count                    = var.default_node_pool.max_count
    enable_auto_scaling          = true
    zones                        = var.default_node_pool.availability_zones
    vnet_subnet_id               = var.subnet_id
    only_critical_addons_enabled = true # system pool runs only system pods

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

  dynamic "api_server_access_profile" {
    for_each = length(var.api_server_authorized_ip_ranges) > 0 ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
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
      default_node_pool[0].node_count, # managed by autoscaler
      kubernetes_version,              # managed via upgrade pipeline
    ]
  }
}
