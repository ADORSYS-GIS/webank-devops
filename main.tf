terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76.0"
    }
  }
}

provider "aws" {
  region = var.region
}



# Call the VPC module
module "vpc" {
  source = "./modules/vpc/VPCs"
}

# Call the Subnets module
module "subnets" {
  source = "./modules/vpc/Subnets"
}

# Call the Node Group module (for EC2 instances)
module "node_group" {
  source = "./modules/vpc/node_group"
}

