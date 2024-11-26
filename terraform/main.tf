locals {
  name     = "webank-${var.name}"
  azs_count = length(var.azs)
  azs = var.azs
  argocdDomain = "${local.name}-argocd.${var.zone_name}"
  tags = {
    Owner       = local.name,
    Environment = var.environment
  }
}