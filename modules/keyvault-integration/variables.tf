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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
