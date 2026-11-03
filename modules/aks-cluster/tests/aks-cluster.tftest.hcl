mock_provider "azurerm" {
  # Computed blocks come back empty from a mock provider, but the module's outputs read them.
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      kubelet_identity = [
        {
          client_id                 = "22222222-2222-2222-2222-222222222222"
          object_id                 = "33333333-3333-3333-3333-333333333333"
          user_assigned_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/kubelet"
        }
      ]
      kube_config = [
        {
          host                   = "https://aks-test.example.com:443"
          username               = "test-user"
          password               = "test-password"
          client_certificate     = "test-cert"
          client_key             = "test-key"
          cluster_ca_certificate = "test-ca"
        }
      ]
    }
  }
}

variables {
  cluster_name        = "aks-test"
  resource_group_name = "rg-test"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-aks"
}

run "secure_defaults" {
  command = apply

  assert {
    condition     = azurerm_kubernetes_cluster.this.local_account_disabled == true
    error_message = "Local Kubernetes admin accounts must be disabled"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.azure_policy_enabled == true
    error_message = "Azure Policy add-on must be enabled"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.role_based_access_control_enabled == true
    error_message = "RBAC must be enabled"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.sku_tier == "Standard"
    error_message = "sku_tier should default to Standard"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.private_cluster_enabled == false
    error_message = "Private cluster is opt-in"
  }
}

run "system_pool_runs_only_critical_addons" {
  command = apply

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].only_critical_addons_enabled == true
    error_message = "The system pool must be tainted for critical add-ons only"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.default_node_pool[0].enable_auto_scaling == true
    error_message = "The system pool must autoscale"
  }
}

run "private_cluster_is_opt_in" {
  command = apply

  variables {
    private_cluster_enabled = true
  }

  assert {
    condition     = azurerm_kubernetes_cluster.this.private_cluster_enabled == true
    error_message = "private_cluster_enabled should be passed through"
  }
}

run "monitoring_only_with_a_workspace" {
  command = apply

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.oms_agent) == 0
    error_message = "No oms_agent block without a Log Analytics workspace"
  }
}

run "monitoring_enabled_with_a_workspace" {
  command = apply

  variables {
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.oms_agent) == 1
    error_message = "oms_agent should be created when a workspace is supplied"
  }
}

run "api_ip_allow_list_is_optional" {
  command = apply

  variables {
    api_server_authorized_ip_ranges = ["203.0.113.0/24"]
  }

  assert {
    condition     = length(azurerm_kubernetes_cluster.this.api_server_access_profile) == 1
    error_message = "api_server_access_profile should be created when ranges are supplied"
  }
}

run "rejects_unknown_sku_tier" {
  command = apply

  variables {
    sku_tier = "Premium"
  }

  expect_failures = [var.sku_tier]
}

run "rejects_unknown_upgrade_channel" {
  command = apply

  variables {
    automatic_channel_upgrade = "weekly"
  }

  expect_failures = [var.automatic_channel_upgrade]
}
