provider "aws" {
  region = local.region  
}

# Local variables for cluster, region, and network configurations
locals {
  name   = "webank-cluster"
  region = "eu-central-1"
  vpc_cidr = "10.123.0.0/16"
  azs      = ["eu-central-1a", "eu-central-1b"]
  public_subnets  = ["10.123.1.0/24", "10.123.2.0/24"]
  private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
  intra_subnets   = ["10.123.5.0/24", "10.123.6.0/24"]
}

# VPC Module: Defines the VPC and subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr
  azs = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true 
}

# EKS Module: Sets up the EKS cluster and node groups
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true  # Allow public access to the EKS endpoint

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Managed Node Group configuration
  eks_managed_node_groups = {
    webank-cluster-wg = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.large"] // we will chang this later to medium or small
      capacity_type  = "SPOT"  
    }
  }
}

# DB Subnet Group: Creates a subnet group for RDS with at least two subnets
resource "aws_db_subnet_group" "postgresql_subnet_group" {
  name       = "postgresql-subnet-group"
  subnet_ids = module.vpc.private_subnets  # Private subnets in the VPC

  tags = {
    Name = "PostgreSQL subnet group"
  }
}

# Security Group for RDS: Allows access to the RDS instance from private subnets
resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"
  vpc_id      = module.vpc.vpc_id

  # Ingress for PostgreSQL access (port 5432)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.private_subnets  # Correctly reference private subnets CIDR blocks
  }

  # Egress rule allows all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Module: Creates a PostgreSQL database instance
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  identifier = "${local.name}-db"
  engine = "postgres"
  engine_version = "17.2"
  instance_class = "db.t3.medium"
  allocated_storage = 10
  db_name = "prodclusterdb"
  username = var.db_username
  password = var.db_password
  publicly_accessible = false  # Database is private

  # DB parameter group
  family = "postgres17"

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.postgresql_subnet_group.name  # Use DB subnet group here
  storage_encrypted = true
  backup_retention_period = 7
}

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

# Variables for database credentials
variable "db_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true  
}
