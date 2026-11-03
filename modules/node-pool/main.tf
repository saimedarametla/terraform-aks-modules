terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.12"
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  #checkov:skip=CKV_AZURE_227:Host encryption needs the EncryptionAtHost subscription feature registered
  #checkov:skip=CKV_AZURE_168:Azure CNI reserves one IP per pod, so 50+ pods per node needs a larger subnet than the default /24
  name                  = var.node_pool_name
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vm_size               = var.vm_size
  mode                  = "User"

  enable_auto_scaling = true
  min_count           = var.min_count
  max_count           = var.max_count
  node_count          = var.min_count

  zones          = var.availability_zones
  vnet_subnet_id = var.subnet_id

  node_taints = var.node_taints
  node_labels = var.node_labels

  os_disk_size_gb = var.os_disk_size_gb
  os_disk_type    = "Ephemeral" # faster, cheaper for stateless workloads

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count] # managed by cluster autoscaler
  }
}
