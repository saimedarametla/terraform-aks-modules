data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                        = "kv-${var.cluster_name}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  tags = var.tags
}

# Grant the AKS kubelet identity access to read secrets
resource "azurerm_key_vault_access_policy" "aks_kubelet" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.kubelet_identity_id

  secret_permissions = var.secret_permissions
}

output "key_vault_id"  { value = azurerm_key_vault.this.id }
output "key_vault_uri" { value = azurerm_key_vault.this.vault_uri }
