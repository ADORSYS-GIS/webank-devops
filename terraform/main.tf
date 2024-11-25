provider "aws" {
  region = var.region
}

locals {
  vpc_cidr = var.vpc_cidr
  azs      = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  intra_subnets   = var.intra_subnets
}
