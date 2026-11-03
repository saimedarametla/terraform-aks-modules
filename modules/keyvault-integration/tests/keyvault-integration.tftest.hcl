mock_provider "azurerm" {}

variables {
  cluster_name        = "aks-test"
  resource_group_name = "rg-test"
  tenant_id           = "00000000-0000-0000-0000-000000000000"
  kubelet_identity_id = "11111111-1111-1111-1111-111111111111"
}

run "vault_is_locked_down_by_default" {
  command = plan

  assert {
    condition     = azurerm_key_vault.this.network_acls[0].default_action == "Deny"
    error_message = "Network access must be denied unless explicitly allowed"
  }

  assert {
    condition     = azurerm_key_vault.this.purge_protection_enabled == true
    error_message = "Purge protection must be on"
  }

  assert {
    condition     = azurerm_key_vault.this.name == "kv-aks-test"
    error_message = "Vault name should be kv-<cluster_name>"
  }
}

run "kubelet_gets_read_only_secret_access" {
  command = plan

  assert {
    condition     = toset(azurerm_key_vault_access_policy.aks_kubelet.secret_permissions) == toset(["Get", "List"])
    error_message = "The kubelet identity should only read secrets by default"
  }
}

run "allowed_subnets_are_added_to_the_rules" {
  command = plan

  variables {
    allowed_subnet_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-aks"]
  }

  assert {
    condition     = length(azurerm_key_vault.this.network_acls[0].virtual_network_subnet_ids) == 1
    error_message = "The supplied subnet should be allowed"
  }
}
