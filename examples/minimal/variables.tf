variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-minimal"
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
