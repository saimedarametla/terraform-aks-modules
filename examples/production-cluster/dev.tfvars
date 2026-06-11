# dev.tfvars
environment          = "dev"
location             = "uksouth"
resource_group_name  = "rg-aks-dev"
kubernetes_version   = "1.29"
vnet_address_space   = ["10.1.0.0/16"]
aks_subnet_prefix    = "10.1.1.0/24"
system_node_vm_size  = "Standard_D2s_v3"
app_node_vm_size     = "Standard_D4s_v3"
tenant_id            = "00000000-0000-0000-0000-000000000000"  # replace with your tenant ID
