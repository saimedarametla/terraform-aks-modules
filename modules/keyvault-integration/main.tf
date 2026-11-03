terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

resource "azurerm_key_vault" "this" {
  #checkov:skip=CKV_AZURE_189:Access is restricted with network ACLs and a service endpoint; a private endpoint needs your own DNS design
  #checkov:skip=CKV2_AZURE_32:Private endpoints are out of scope for this module
  name                       = "kv-${var.cluster_name}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# Grant the AKS kubelet identity access to read secrets
resource "azurerm_key_vault_access_policy" "aks_kubelet" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.kubelet_identity_id

  secret_permissions = var.secret_permissions
}
