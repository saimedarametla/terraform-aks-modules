variable "cluster_name" {
  description = "Cluster name, used to name the Key Vault (kv-<cluster_name>)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "Resource group to deploy into"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "kubelet_identity_id" {
  description = "Object ID of AKS kubelet managed identity"
  type        = string
}

variable "secret_permissions" {
  description = "Secret permissions granted to the kubelet identity"
  type        = list(string)
  default     = ["Get", "List"]
}

variable "allowed_subnet_ids" {
  description = "Subnets allowed to reach the vault. They need the Microsoft.KeyVault service endpoint (the networking module adds it). Include the AKS subnet or the CSI driver cannot read secrets."
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "Public IPs or CIDR ranges allowed to reach the vault, for example a build agent that writes secrets."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
