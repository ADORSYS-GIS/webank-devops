# Outputs: Exposes important resource details for further use
output "eks_cluster_name" {
  value = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_port" {
  value = module.rds.db_instance_port
}