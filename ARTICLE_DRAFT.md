# How I Structured Reusable Terraform Modules for Enterprise AKS Deployments

*Published on [Medium](https://medium.com) / [dev.to](https://dev.to)*

---

When I was working on cloud infrastructure delivery at British Telecom, one problem kept coming up: every new client environment started from scratch. Someone would copy-paste Terraform from the last project, rename a few things, and hope nothing was missed. The result was environment drift, inconsistent security configurations, and onboarding new clients taking days instead of hours.

The solution was building a proper module structure — one that encoded the right decisions once, and made it easy to deploy a consistent, production-grade AKS cluster for any new environment by changing a `.tfvars` file.

This article walks through the structure I settled on, the decisions behind it, and the patterns that made the biggest difference in practice.

---

## The problem with ad-hoc AKS Terraform

Most AKS Terraform I encountered in the wild looked like one enormous `main.tf` — everything inline, no modules, hardcoded values everywhere. It works for a single environment, but it falls apart when you need to:

- Reproduce the same infrastructure across dev, UAT, and production
- Onboard a new client with slightly different sizing but the same security baseline
- Enforce consistent configuration (RBAC, Key Vault integration, network policy) without relying on everyone remembering to do it

The answer is modules. Not just wrapping resources in a module for the sake of it — but designing modules around the decisions you actually need to vary between environments.

---

## The module structure

After a few iterations, I landed on four modules that cover the full stack for a production AKS deployment:

```
modules/
├── aks-cluster          # Core cluster, identity, RBAC, monitoring
├── node-pool            # Additional user node pools (workload isolation)
├── networking           # VNet, subnets, NSGs for Azure CNI
└── keyvault-integration # Key Vault + Secrets Store CSI Driver
```

Each module has a clear responsibility. They compose together but can also be used independently if you already have a VNet, for example.

---

## The `aks-cluster` module — decisions worth encoding

The core cluster module is where most of the important defaults live. Here are the ones that made the biggest difference:

### System-assigned managed identity over service principals

```hcl
identity {
  type = "SystemAssigned"
}
```

Service principals have expiry dates. Someone inevitably forgets to rotate them. Managed identity removes that problem entirely — Azure handles the credential lifecycle. Every production cluster I've deployed since 2022 uses managed identity.

### Dedicated system node pool

```hcl
only_critical_addons_enabled = true
```

This one line restricts the system node pool to system pods only (CoreDNS, metrics-server, etc.). Application workloads go on user node pools. The benefit: system components never get evicted because an application consumed all the memory on a node. In production this matters — a DNS outage because your app ate the node is not a fun incident to debug.

### Azure CNI over kubenet

```hcl
network_profile {
  network_plugin = "azure"
  network_policy = "azure"
}
```

Kubenet uses NAT for pod networking which creates complexity for anything that needs to reach pods directly (service meshes, direct pod networking, some monitoring tools). Azure CNI gives every pod a real IP on the VNet. The tradeoff is IP address consumption — you need to size your subnet to accommodate `max_nodes × max_pods_per_node`. Worth it for enterprise environments where you're running service meshes or need predictable network behaviour.

### Lifecycle ignore for node count

```hcl
lifecycle {
  ignore_changes = [
    default_node_pool[0].node_count,
  ]
}
```

Without this, every `terraform plan` after the cluster autoscaler has adjusted node count will show a drift. The autoscaler is managing node count at runtime — Terraform should not fight it. This is a small thing but it eliminates a lot of noise in your CI/CD `plan` output.

---

## The `node-pool` module — workload isolation

Separate node pools for different workload types is a pattern I've found consistently valuable. The key variables are `node_taints` and `node_labels`:

```hcl
module "app_node_pool" {
  source         = "../../modules/node-pool"
  node_pool_name = "apppool"
  node_taints    = ["workload=app:NoSchedule"]
  node_labels    = { "workload" = "app" }
  vm_size        = "Standard_D8s_v3"
  min_count      = 2
  max_count      = 10
}
```

Pods that need to run on this pool set a toleration and a node selector:

```yaml
tolerations:
  - key: "workload"
    operator: "Equal"
    value: "app"
    effect: "NoSchedule"
nodeSelector:
  workload: "app"
```

This means system workloads never land on your application nodes and vice versa. For cost optimisation, you can use different VM sizes per pool — cheaper VMs for batch jobs, more RAM for memory-intensive services.

---

## Multi-environment promotion

The pattern that saved the most time was using the same `main.tf` across all environments with environment-specific `.tfvars`:

```
examples/production-cluster/
├── main.tf       # module calls — identical across envs
├── variables.tf
├── dev.tfvars    # small VMs, min_count=1
├── uat.tfvars    # medium VMs, min_count=2
└── prod.tfvars   # production VMs, min_count=3, AZs enabled
```

Deploying a new environment is one command:

```bash
terraform apply -var-file="dev.tfvars"
```

When I needed to onboard a new client at BT, I created a new `.tfvars` file, set the resource group and sizing, and ran `apply`. The security baseline, RBAC configuration, and monitoring setup came for free from the modules. What previously took a day or more was done in under an hour.

---

## Key Vault integration — no secrets in manifests

The `keyvault-integration` module wires Key Vault to AKS using the Secrets Store CSI Driver, which ships as a built-in add-on since AKS 1.21:

```hcl
key_vault_secrets_provider {
  secret_rotation_enabled  = true
  secret_rotation_interval = "2m"
}
```

With this enabled, secrets are mounted directly into pods as volumes — no secrets hardcoded in Kubernetes manifests, no environment variables containing credentials. The kubelet managed identity gets `Get` and `List` permissions on Key Vault, and nothing else.

```yaml
# SecretProviderClass example
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kv-secrets
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: ""
    keyvaultName: "kv-aks-prod-001"
    tenantId: "<your-tenant-id>"
    objects: |
      array:
        - |
          objectName: db-connection-string
          objectType: secret
```

---

## What I'd do differently

A few things I'd change with hindsight:

**Add a `maintenance_window` variable.** I hardcoded Sunday 01:00–03:00 UTC. That worked for UK clients but is wrong for anything in APAC. Should be configurable per environment.

**Remote state from day one.** The example uses local state by default with a commented-out backend block. In practice, local state is fine for development but you want Azure Storage backend before you run this in CI/CD. Should be the default, not an afterthought.

**Separate the Log Analytics workspace.** I passed in a workspace ID as an input, which is correct — but I've seen teams create a new workspace per cluster. One workspace shared across clusters is much easier to query and considerably cheaper.

---

## The repo

Full code is on GitHub: [github.com/scmedarametla/terraform-aks-modules](https://github.com/scmedarametla/terraform-aks-modules)

It includes all four modules, the production cluster example with dev/uat/prod tfvars, and a GitHub Actions workflow that runs `fmt`, `validate`, and `plan` on every PR.

Issues and PRs welcome — particularly if you have patterns for Windows node pools or GPU workloads, which I haven't needed yet but know others do.

---

*Sai Medarametla is a Hybrid Cloud & DevOps Engineer based in London, with 6+ years designing enterprise infrastructure across AWS, Azure, and GCP.*
