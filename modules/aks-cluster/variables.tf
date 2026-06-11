variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region (e.g. uksouth, eastus)"
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "Resource group to deploy the cluster into"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version — check az aks get-versions for available versions"
  type        = string
  default     = "1.29"
}

variable "subnet_id" {
  description = "Subnet resource ID for AKS node placement (Azure CNI)"
  type        = string
}

variable "private_cluster_enabled" {
  description = "Deploy AKS with a private API server endpoint"
  type        = bool
  default     = false
}

variable "default_node_pool" {
  description = "Configuration for the system (default) node pool"
  type = object({
    vm_size            = string
    node_count         = number
    min_count          = number
    max_count          = number
    availability_zones = optional(list(string), ["1", "2", "3"])
  })
  default = {
    vm_size    = "Standard_D4s_v3"
    node_count = 3
    min_count  = 2
    max_count  = 5
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for OMS agent (monitoring)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
