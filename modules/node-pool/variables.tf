variable "node_pool_name" {
  description = "Node pool name — lowercase, max 12 characters"
  type        = string
  validation {
    condition     = length(var.node_pool_name) <= 12 && can(regex("^[a-z][a-z0-9]*$", var.node_pool_name))
    error_message = "Node pool name must be lowercase alphanumeric, max 12 characters, starting with a letter."
  }
}

variable "kubernetes_cluster_id" {
  description = "Resource ID of the parent AKS cluster"
  type        = string
}

variable "vm_size" {
  description = "Azure VM SKU for nodes in this pool"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "min_count" {
  description = "Minimum node count for autoscaler"
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Maximum node count for autoscaler"
  type        = number
  default     = 10
}

variable "availability_zones" {
  description = "Availability zones to spread nodes across"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "subnet_id" {
  description = "Subnet resource ID for node placement"
  type        = string
}

variable "node_taints" {
  description = "Kubernetes taints to apply to nodes (e.g. ['workload=app:NoSchedule'])"
  type        = list(string)
  default     = []
}

variable "node_labels" {
  description = "Labels to apply to nodes in this pool"
  type        = map(string)
  default     = {}
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 128
}

variable "tags" {
  description = "Tags to apply to the node pool resource"
  type        = map(string)
  default     = {}
}
