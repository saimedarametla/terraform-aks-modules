variable "cluster_name"        { type = string }
variable "location"            { type = string; default = "uksouth" }
variable "resource_group_name" { type = string }
variable "tenant_id"           { type = string }
variable "kubelet_identity_id" { type = string; description = "Object ID of AKS kubelet managed identity" }
variable "secret_permissions"  { type = list(string); default = ["Get", "List"] }
variable "tags"                { type = map(string); default = {} }
