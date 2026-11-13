# Changelog

All notable changes are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [3.0.0] - 2026-11-13

Upgrades all modules to azurerm 5.x. Existing users must update their provider version and rename one `aks-cluster` input before upgrading.

### Added
- `aks-cluster`: optional `admin_group_object_ids` input to give Entra ID groups cluster admin access

### Changed
- **Breaking:** azurerm provider upgraded from `~> 3.100` to `~> 5.13`
- **Breaking:** minimum Terraform version raised from `>= 1.3` to `>= 1.7`, required by the mock providers used in tests
- **Breaking:** `aks-cluster` input `automatic_channel_upgrade` renamed to `automatic_upgrade_channel` to match the provider
- `aks-cluster`: added the now-required `node_provisioning_profile` block with `mode = "Manual"`, so node pools stay defined in Terraform
- `aks-cluster` and `node-pool`: `enable_auto_scaling` renamed to `auto_scaling_enabled`
- `aks-cluster`: removed `managed` from the Entra ID RBAC block (always on in azurerm 5.x); the tenant now comes from the current Azure login
- `networking`: subnet service endpoint moved to the new `service_endpoint` block
- `keyvault-integration`: set the now-required `rbac_authorization_enabled = false` to keep access policies working

## [2.0.0] - 2026-11-03

This release changes secure defaults, so existing users should read the **Changed** section before upgrading.

### Added
- `aks-cluster`: `sku_tier` (default `Standard`), `automatic_channel_upgrade` and `api_server_authorized_ip_ranges` options
- `keyvault-integration`: `allowed_subnet_ids` and `allowed_ip_ranges`
- `examples/minimal`: smallest working cluster
- Automated tests with `terraform test` for every module
- Generated module documentation, checked in CI
- Dependabot, issue and pull request templates, pre-commit config, release workflow

### Changed
- **Breaking:** `aks-cluster` disables local Kubernetes admin accounts (Azure AD only) and enables the Azure Policy add-on
- **Breaking:** `aks-cluster` `sku_tier` defaults to `Standard` (paid uptime SLA); set `Free` for dev
- **Breaking:** `keyvault-integration` network ACLs deny by default; pass `allowed_subnet_ids` or `allowed_ip_ranges`
- `networking`: AKS subnet gets the `Microsoft.KeyVault` service endpoint
- Deliberate Checkov skips are recorded next to each resource with the reason

## [1.0.0] - 2026-11-03

### Added
- `networking`, `aks-cluster`, `node-pool` and `keyvault-integration` modules
- `examples/production-cluster` with dev, uat and prod sizing
- CI: `terraform fmt`, `validate`, `tflint` and `checkov`

### Fixed
- Invalid single-line variable blocks that broke `terraform validate`
- azurerm 3.x argument name (`zones`, not `availability_zones`)
- `oms_agent` is only created when a Log Analytics workspace is supplied
- Ephemeral OS disk default lowered to fit the VM cache