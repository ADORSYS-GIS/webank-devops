provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  name     = "webank-${var.name}"
  azs_count = length(var.azs)
  azs = var.azs
  tags = {
    Owner       = local.name,
    Environment = var.environment
  }
}