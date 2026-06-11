resource "azurerm_kubernetes_cluster_node_pool" "this" {
  name                  = var.node_pool_name
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vm_size               = var.vm_size
  mode                  = "User"

  enable_auto_scaling = true
  min_count           = var.min_count
  max_count           = var.max_count
  node_count          = var.min_count

  availability_zones = var.availability_zones
  vnet_subnet_id     = var.subnet_id

  node_taints  = var.node_taints
  node_labels  = var.node_labels

  os_disk_size_gb = var.os_disk_size_gb
  os_disk_type    = "Ephemeral"   # faster, cheaper for stateless workloads

  upgrade_settings {
    max_surge = "33%"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count]  # managed by cluster autoscaler
  }
}
