variable "environment"                 { type = string; description = "dev | uat | prod" }
variable "location"                    { type = string; default = "uksouth" }
variable "resource_group_name"         { type = string }
variable "kubernetes_version"          { type = string; default = "1.29" }
variable "vnet_address_space"          { type = list(string); default = ["10.0.0.0/16"] }
variable "aks_subnet_prefix"           { type = string; default = "10.0.1.0/24" }
variable "system_node_vm_size"         { type = string; default = "Standard_D4s_v3" }
variable "app_node_vm_size"            { type = string; default = "Standard_D8s_v3" }
variable "tenant_id"                   { type = string }
variable "log_analytics_workspace_id"  { type = string; default = null }
