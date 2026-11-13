# keyvault-integration

Key Vault with soft delete, purge protection and default-deny network rules, plus read access for the AKS kubelet identity.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7 |
| azurerm | ~> 5.13 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 5.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.aks_kubelet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Cluster name, used to name the Key Vault (kv-<cluster\_name>) | `string` | n/a | yes |
| kubelet\_identity\_id | Object ID of AKS kubelet managed identity | `string` | n/a | yes |
| resource\_group\_name | Resource group to deploy into | `string` | n/a | yes |
| tenant\_id | Azure AD tenant ID | `string` | n/a | yes |
| allowed\_ip\_ranges | Public IPs or CIDR ranges allowed to reach the vault, for example a build agent that writes secrets. | `list(string)` | `[]` | no |
| allowed\_subnet\_ids | Subnets allowed to reach the vault. They need the Microsoft.KeyVault service endpoint (the networking module adds it). Include the AKS subnet or the CSI driver cannot read secrets. | `list(string)` | `[]` | no |
| location | Azure region | `string` | `"uksouth"` | no |
| secret\_permissions | Secret permissions granted to the kubelet identity | `list(string)` | ```[ "Get", "List" ]``` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| key\_vault\_id | Resource ID of the Key Vault |
| key\_vault\_uri | URI of the Key Vault |
<!-- END_TF_DOCS -->
