provider "aws" {
  region = var.region
}

locals {
  name     = "webank-${var.name}"
  azs_count = length(var.azs)
  azs = var.azs
  tags = {
    Owner       = local.name,
    Environment = var.environment
  }
}