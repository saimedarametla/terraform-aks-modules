variable "cluster_name"        { type = string }
variable "location"            { type = string; default = "uksouth" }
variable "resource_group_name" { type = string }
variable "vnet_address_space"  { type = list(string); default = ["10.0.0.0/16"] }
variable "aks_subnet_prefix"   { type = string; default = "10.0.1.0/24" }
variable "enable_nat_gateway"  { type = bool; default = false }
variable "tags"                { type = map(string); default = {} }
