provider "aws" {
  region = local.region
}

# Local variables for cluster, region, and network configurations
locals {
  name     = "webank-${var.name}"
  region   = var.region
  vpc_cidr = "10.55.0.0/16"
  azs_count = length(var.azs)
  azs = slice(var.azs, 0, local.azs_count)
  tags = {
    Owner       = var.name,
    Environment = var.environment
  }
}

# VPC Module: Defines the VPC and subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name             = "${local.name}-vpc"
  cidr             = local.vpc_cidr
  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + local.azs_count)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 2*local.azs_count)]

  enable_nat_gateway           = true
  create_database_subnet_group = true

  tags = merge(
    local.tags,
    {
      "kubernetes.io/cluster/${local.name}" = "shared"
    }
  )
}

# EKS Module: Sets up the EKS cluster and node groups
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name = "${local.name}-cluster"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Managed Node Group configuration
  eks_managed_node_groups = {
    webank-cluster-wg = {
      min_size      = 1
      max_size      = 2
      desired_size  = 1
      instance_types = [var.ec2_instance]
      capacity_type = "SPOT"
    }
  }

  tags = merge(
    local.tags,
    {
      "kubernetes.io/cluster/${local.name}-cluster" = "shared"
    }
  )
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-sg"
  description = "Complete PostgreSQL example security group"
  vpc_id = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = merge(
    local.tags,
    {}
  )
}

# RDS Module: Creates a PostgreSQL database instance
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier                     = "${local.name}-db"
  instance_use_identifier_prefix = true
  engine                         = "postgres"
  engine_version                 = "17.2"
  instance_class                 = var.db_instance
  allocated_storage              = 10
  db_name = replace("${local.name}-db", "-", "_")
  username                       = var.db_username
  password                       = var.db_password
  publicly_accessible            = false  # Database is private

  # DB parameter group
  family = "postgres17"

  db_subnet_group_name = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  storage_encrypted       = true
  backup_retention_period = var.db_backup_retention_period

  skip_final_snapshot = true
  deletion_protection = false

  create_db_subnet_group = false
  create_random_password = false

  create_cloudwatch_log_group = false

  tags = merge(
    local.tags,
    {}
  )
}