module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = var.name
  cluster_endpoint_public_access = true

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    webank-cluster-wg = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }
}
