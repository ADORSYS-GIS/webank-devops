output "region" {
  description = "AWS region"
  value       = var.region
}

output "debug_private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "debug_vpc_id" {
  value = module.vpc.vpc_id
}

