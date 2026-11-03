variable "environment" {
  description = "dev | uat | prod"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "Existing resource group to deploy into"
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version (check az aks get-versions). Null uses the AKS default."
  type        = string
  default     = null
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "CIDR prefix for the AKS subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "system_node_vm_size" {
  description = "VM size for the system node pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "app_node_vm_size" {
  description = "VM size for the application node pool"
  type        = string
  default     = "Standard_D8s_v3"
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for monitoring"
  type        = string
  default     = null
}
