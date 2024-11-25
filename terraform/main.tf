provider "aws" {
  region = var.region
}

locals {
  azs_count = length(var.azs)
  azs      = var.azs
  tags = {
    Owner       = var.name,
    Environment = var.environment
  }
}