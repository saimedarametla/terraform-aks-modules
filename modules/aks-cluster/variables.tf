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
  description = "Kubernetes version (check az aks get-versions). Null lets AKS pick its current default; later changes are ignored and handled via your upgrade process."
  type        = string
  default     = null
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

variable "sku_tier" {
  description = "AKS control plane tier. Standard adds the uptime SLA and is recommended for production; Free is fine for dev."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "sku_tier must be Free or Standard."
  }
}

variable "automatic_upgrade_channel" {
  description = "Automatic upgrade channel: patch, rapid, stable or node-image. Null leaves upgrades to your own pipeline. With patch, set kubernetes_version to a minor version such as 1.30."
  type        = string
  default     = null
  validation {
    condition     = var.automatic_upgrade_channel == null || contains(["patch", "rapid", "stable", "node-image"], coalesce(var.automatic_upgrade_channel, "none"))
    error_message = "automatic_upgrade_channel must be null, patch, rapid, stable or node-image."
  }
}

variable "api_server_authorized_ip_ranges" {
  description = "CIDR ranges allowed to reach the public API server. Empty means unrestricted. Not supported together with private_cluster_enabled."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for Container Insights. Null disables the OMS agent."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
