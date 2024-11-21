resource "aws_subnet" "private-1" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.cidr_blocks.private_1
  availability_zone = var.availability_zones[0]

  tags = {
    "Name"                            = "private-${var.availability_zones[0]}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/webank"    = "owned"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.cidr_blocks.private_2
  availability_zone = var.availability_zones[1]

  tags = {
    "Name"                            = "private-${var.availability_zones[1]}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/webank"    = "owned"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.cidr_blocks.public_1
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-${var.availability_zones[0]}"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/webank" = "owned"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.cidr_blocks.public_2
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "public-${var.availability_zones[1]}"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/webank" = "owned"
  }
}


module "vpc" {
  source = "../VPCs"
}



