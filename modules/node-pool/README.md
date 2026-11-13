# node-pool

Autoscaling user node pool with taints, labels, availability zones and ephemeral OS disks.

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
| [azurerm_kubernetes_cluster_node_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| kubernetes\_cluster\_id | Resource ID of the parent AKS cluster | `string` | n/a | yes |
| node\_pool\_name | Node pool name — lowercase, max 12 characters | `string` | n/a | yes |
| subnet\_id | Subnet resource ID for node placement | `string` | n/a | yes |
| availability\_zones | Availability zones to spread nodes across | `list(string)` | ```[ "1", "2", "3" ]``` | no |
| max\_count | Maximum node count for autoscaler | `number` | `10` | no |
| min\_count | Minimum node count for autoscaler | `number` | `2` | no |
| node\_labels | Labels to apply to nodes in this pool | `map(string)` | `{}` | no |
| node\_taints | Kubernetes taints to apply to nodes (e.g. ['workload=app:NoSchedule']) | `list(string)` | `[]` | no |
| os\_disk\_size\_gb | OS disk size in GB. Ephemeral OS disks must fit in the VM SKU's cache (about 100 GB for Standard\_D4s\_v3), so keep this at or below that. | `number` | `64` | no |
| tags | Tags to apply to the node pool resource | `map(string)` | `{}` | no |
| vm\_size | Azure VM SKU for nodes in this pool | `string` | `"Standard_D4s_v3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| node\_pool\_id | Resource ID of the node pool |
| node\_pool\_name | Name of the node pool |
<!-- END_TF_DOCS -->
