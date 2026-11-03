mock_provider "azurerm" {}

variables {
  cluster_name        = "aks-test"
  resource_group_name = "rg-test"
}

run "names_are_derived_from_cluster_name" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.this.name == "vnet-aks-test"
    error_message = "VNet name should be vnet-<cluster_name>"
  }

  assert {
    condition     = azurerm_network_security_group.aks.name == "nsg-aks-aks-test"
    error_message = "NSG name should be nsg-aks-<cluster_name>"
  }
}

run "subnet_has_key_vault_service_endpoint" {
  command = plan

  assert {
    condition     = contains(azurerm_subnet.aks.service_endpoints, "Microsoft.KeyVault")
    error_message = "The AKS subnet needs the Microsoft.KeyVault service endpoint for the vault network rules"
  }
}

run "address_ranges_are_configurable" {
  command = plan

  variables {
    vnet_address_space = ["10.1.0.0/16"]
    aks_subnet_prefix  = "10.1.1.0/24"
  }

  assert {
    condition     = azurerm_subnet.aks.address_prefixes[0] == "10.1.1.0/24"
    error_message = "aks_subnet_prefix should be used for the subnet"
  }
}
