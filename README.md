# terraform-aks-modules

> Reusable Terraform modules for production-grade Azure Kubernetes Service (AKS) deployments.
> Built from patterns developed across enterprise multi-client infrastructure delivery.

[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.3-623CE4)](https://www.terraform.io/)
[![AzureRM](https://img.shields.io/badge/azurerm-%3E%3D3.50-0078D4)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Why this exists

Deploying AKS in enterprise environments means repeating the same decisions across every project: cluster sizing, node pool isolation, networking mode, Key Vault integration, HA/DR configuration. Doing this ad-hoc leads to environment drift, inconsistent security posture, and slow client onboarding.

These modules encode the patterns I found most reliable across multiple production deployments — sensible defaults, clearly documented overrides, and a structure that makes multi-environment promotion (dev → UAT → production) straightforward.

---

## Modules

| Module | Description |
|--------|-------------|
| [`aks-cluster`](./modules/aks-cluster) | Core AKS cluster with system node pool, RBAC, and managed identity |
| [`node-pool`](./modules/node-pool) | Additional user node pools with configurable VM size, autoscaling, and taints |
| [`networking`](./modules/networking) | VNet, subnets, and NSG configuration for AKS CNI networking |
| [`keyvault-integration`](./modules/keyvault-integration) | Azure Key Vault + Secrets Store CSI Driver integration for secret injection |

---

## Quick start

```hcl
module "networking" {
  source              = "./modules/networking"
  resource_group_name = "rg-aks-prod"
  location            = "uksouth"
  vnet_address_space  = ["10.0.0.0/16"]
  aks_subnet_prefix   = "10.0.1.0/24"
}

module "aks_cluster" {
  source              = "./modules/aks-cluster"
  cluster_name        = "aks-prod-001"
  resource_group_name = "rg-aks-prod"
  location            = "uksouth"
  kubernetes_version  = "1.29"
  subnet_id           = module.networking.aks_subnet_id

  default_node_pool = {
    vm_size    = "Standard_D4s_v3"
    node_count = 3
    min_count  = 2
    max_count  = 5
  }

  tags = {
    environment = "production"
    managed_by  = "terraform"
  }
}

module "app_node_pool" {
  source            = "./modules/node-pool"
  node_pool_name    = "apppool"
  kubernetes_cluster_id = module.aks_cluster.cluster_id
  vm_size           = "Standard_D8s_v3"
  min_count         = 2
  max_count         = 10
  node_taints       = ["workload=app:NoSchedule"]
  subnet_id         = module.networking.aks_subnet_id
}

module "keyvault" {
  source              = "./modules/keyvault-integration"
  cluster_name        = module.aks_cluster.cluster_name
  resource_group_name = "rg-aks-prod"
  location            = "uksouth"
  tenant_id           = var.tenant_id
  kubelet_identity_id = module.aks_cluster.kubelet_identity_object_id
}
```

---

## Multi-environment pattern

This repo is structured for multi-environment promotion. Each environment (`dev`, `uat`, `prod`) uses the same modules with different `.tfvars` files:

```
examples/
└── production-cluster/
    ├── main.tf          # module calls
    ├── variables.tf
    ├── dev.tfvars
    ├── uat.tfvars
    └── prod.tfvars
```

```bash
# Deploy to dev
terraform apply -var-file="dev.tfvars"

# Promote to production
terraform apply -var-file="prod.tfvars"
```

---

## Module details

### `aks-cluster`

Creates a production-ready AKS cluster with:
- System-assigned managed identity (no service principals to rotate)
- Azure CNI networking (required for direct pod IP assignment)
- RBAC enabled with Azure AD integration
- Cluster autoscaler on the system node pool
- Optional private cluster mode
- Diagnostic settings wired to Log Analytics

**Key inputs:**

| Variable | Type | Description |
|----------|------|-------------|
| `cluster_name` | `string` | AKS cluster name |
| `kubernetes_version` | `string` | K8s version (e.g. `"1.29"`) |
| `subnet_id` | `string` | Subnet resource ID for node placement |
| `default_node_pool` | `object` | VM size, min/max count for system pool |
| `private_cluster_enabled` | `bool` | Enable private API server (default: `false`) |
| `log_analytics_workspace_id` | `string` | Optional — enables diagnostic logs |

**Key outputs:**

| Output | Description |
|--------|-------------|
| `cluster_id` | AKS resource ID |
| `cluster_name` | Cluster name |
| `kube_config` | kubeconfig (sensitive) |
| `kubelet_identity_object_id` | Used for Key Vault access policy |

---

### `node-pool`

Adds a user node pool to an existing AKS cluster. Designed for workload isolation — separate pools for application workloads, batch jobs, or GPU nodes.

**Key inputs:**

| Variable | Type | Description |
|----------|------|-------------|
| `node_pool_name` | `string` | Must be lowercase, max 12 chars |
| `kubernetes_cluster_id` | `string` | Output from `aks-cluster` module |
| `vm_size` | `string` | Azure VM SKU |
| `min_count` / `max_count` | `number` | Autoscaler bounds |
| `node_taints` | `list(string)` | Kubernetes taints for workload isolation |
| `node_labels` | `map(string)` | Labels for node selector targeting |

---

### `networking`

Creates the VNet and subnet layout required for AKS CNI mode. Includes NSG rules for AKS control plane communication.

**Key inputs:**

| Variable | Type | Description |
|----------|------|-------------|
| `vnet_address_space` | `list(string)` | VNet CIDR (e.g. `["10.0.0.0/16"]`) |
| `aks_subnet_prefix` | `string` | Subnet CIDR for AKS nodes |
| `enable_nat_gateway` | `bool` | Route outbound traffic via NAT Gateway |

---

### `keyvault-integration`

Wires Azure Key Vault to AKS using the Secrets Store CSI Driver. Secrets are mounted as volumes or synced to Kubernetes secrets — no hardcoded credentials in manifests.

**Key inputs:**

| Variable | Type | Description |
|----------|------|-------------|
| `kubelet_identity_id` | `string` | Cluster's kubelet managed identity object ID |
| `secret_permissions` | `list(string)` | Default: `["Get", "List"]` |

---

## HA/DR configuration

For production clusters, enable availability zones across the node pool:

```hcl
module "aks_cluster" {
  # ...
  default_node_pool = {
    vm_size             = "Standard_D4s_v3"
    availability_zones  = ["1", "2", "3"]
    min_count           = 3
    max_count           = 9
  }
}
```

Pair with Azure Site Recovery (ASR) for stateful workload DR and geo-redundant ACR for container images.

---

## CI/CD integration

These modules are designed to run inside Azure DevOps pipelines. See `.github/workflows/terraform-validate.yml` for a GitHub Actions equivalent that runs `fmt`, `validate`, and `plan` on every PR.

---

## Requirements

| Tool | Version |
|------|---------|
| Terraform | >= 1.3 |
| AzureRM provider | >= 3.50 |
| Azure CLI | >= 2.50 (for local auth) |

---

## Contributing

Issues and PRs welcome. If you have patterns from your own AKS deployments — node pool configurations, security baselines, cost optimisation settings — open a PR.

---

## Author

**Sai Medarametla** — Hybrid Cloud & DevOps Engineer, London UK  
6+ years designing enterprise-grade cloud infrastructure across AWS, Azure, and GCP.  
[LinkedIn](https://linkedin.com/in/your-profile) · [Medium](https://medium.com/@your-handle)

---

## Licence

MIT — free to use, modify, and distribute.
