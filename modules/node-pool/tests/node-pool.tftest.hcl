mock_provider "azurerm" {}

variables {
  node_pool_name        = "apppool"
  kubernetes_cluster_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ContainerService/managedClusters/aks-test"
  subnet_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-aks"
}

run "user_pool_defaults" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.this.mode == "User"
    error_message = "This module creates user pools"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.this.auto_scaling_enabled == true
    error_message = "Pools must autoscale"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.this.os_disk_type == "Ephemeral"
    error_message = "Ephemeral OS disks are the default"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.this.os_disk_size_gb == 64
    error_message = "Default OS disk size must fit the VM cache for ephemeral disks"
  }
}

run "taints_and_labels_are_applied" {
  command = plan

  variables {
    node_taints = ["workload=app:NoSchedule"]
    node_labels = { workload = "app" }
  }

  assert {
    condition     = contains(azurerm_kubernetes_cluster_node_pool.this.node_taints, "workload=app:NoSchedule")
    error_message = "node_taints should be applied"
  }

  assert {
    condition     = azurerm_kubernetes_cluster_node_pool.this.node_labels["workload"] == "app"
    error_message = "node_labels should be applied"
  }
}

run "rejects_names_longer_than_12_characters" {
  command = plan

  variables {
    node_pool_name = "thisnameistoolong"
  }

  expect_failures = [var.node_pool_name]
}

run "rejects_uppercase_names" {
  command = plan

  variables {
    node_pool_name = "AppPool"
  }

  expect_failures = [var.node_pool_name]
}
