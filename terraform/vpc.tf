module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr
  azs  = var.azs

  public_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + local.azs_count)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 2 * local.azs_count)]
  intra_subnets    = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 4 * local.azs_count)]

  enable_nat_gateway           = true
  create_database_subnet_group = true

  tags = merge(
    local.tags,
    {
      "kubernetes.io/cluster/${local.name}-eks" = "shared"
    }
  )
}