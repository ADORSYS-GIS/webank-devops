output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "The endpoint of the RDS database instance"
  value       = module.rds.db_instance_endpoint
}

output "rds_port" {
  description = "The port on which the RDS instance is accessible"
  value       = module.rds.db_instance_port
}

output "vpc_id" {
  description = "The ID of the VPC created"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "intra_subnets" {
  description = "List of internal subnet IDs"
  value       = module.vpc.intra_subnets
}
