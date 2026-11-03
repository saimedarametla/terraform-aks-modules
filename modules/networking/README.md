# networking

VNet, an AKS subnet (with the Microsoft.KeyVault service endpoint) and a network security group attached to the subnet.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| azurerm | ~> 3.100 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.100 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Cluster name, used to name the VNet and NSG | `string` | n/a | yes |
| resource\_group\_name | Resource group to deploy into | `string` | n/a | yes |
| aks\_subnet\_prefix | CIDR prefix for the AKS subnet | `string` | `"10.0.1.0/24"` | no |
| location | Azure region | `string` | `"uksouth"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| vnet\_address\_space | Address space for the virtual network | `list(string)` | ```[ "10.0.0.0/16" ]``` | no |

## Outputs

| Name | Description |
|------|-------------|
| aks\_subnet\_id | Resource ID of the AKS subnet |
| vnet\_id | Resource ID of the virtual network |
<!-- END_TF_DOCS -->
