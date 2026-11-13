# aks-cluster

AKS cluster with Azure CNI, Azure AD RBAC (local accounts disabled), a zonal autoscaling system pool restricted to critical add-ons, the Key Vault CSI driver, the Azure Policy add-on, and optional Container Insights, private API server and API IP allow-list.

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
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of the AKS cluster | `string` | n/a | yes |
| resource\_group\_name | Resource group to deploy the cluster into | `string` | n/a | yes |
| subnet\_id | Subnet resource ID for AKS node placement (Azure CNI) | `string` | n/a | yes |
| admin\_group\_object\_ids | Object IDs of Entra ID groups given cluster admin access. Local accounts are disabled, so set this to manage the cluster with kubectl. | `list(string)` | `[]` | no |
| api\_server\_authorized\_ip\_ranges | CIDR ranges allowed to reach the public API server. Empty means unrestricted. Not supported together with private\_cluster\_enabled. | `list(string)` | `[]` | no |
| automatic\_upgrade\_channel | Automatic upgrade channel: patch, rapid, stable or node-image. Null leaves upgrades to your own pipeline. With patch, set kubernetes\_version to a minor version such as 1.30. | `string` | `null` | no |
| default\_node\_pool | Configuration for the system (default) node pool | ```object({ vm_size = string node_count = number min_count = number max_count = number availability_zones = optional(list(string), ["1", "2", "3"]) })``` | ```{ "max_count": 5, "min_count": 2, "node_count": 3, "vm_size": "Standard_D4s_v3" }``` | no |
| kubernetes\_version | Kubernetes version (check az aks get-versions). Null lets AKS pick its current default; later changes are ignored and handled via your upgrade process. | `string` | `null` | no |
| location | Azure region (e.g. uksouth, eastus) | `string` | `"uksouth"` | no |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for Container Insights. Null disables the OMS agent. | `string` | `null` | no |
| private\_cluster\_enabled | Deploy AKS with a private API server endpoint | `bool` | `false` | no |
| sku\_tier | AKS control plane tier. Standard adds the uptime SLA and is recommended for production; Free is fine for dev. | `string` | `"Standard"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_id | Resource ID of the AKS cluster |
| cluster\_identity\_principal\_id | Principal ID of the cluster system-assigned managed identity |
| cluster\_name | Name of the AKS cluster |
| kube\_config | kubeconfig for kubectl access (sensitive) |
| kube\_config\_host | AKS API server endpoint |
| kubelet\_identity\_object\_id | Object ID of the kubelet managed identity — used for Key Vault access policies |
| node\_resource\_group | Auto-generated resource group where AKS node VMs are placed |
<!-- END_TF_DOCS -->
