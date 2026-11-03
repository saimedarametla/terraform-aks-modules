output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks_cluster.cluster_name
}

output "cluster_id" {
  description = "Resource ID of the AKS cluster"
  value       = module.aks_cluster.cluster_id
}
