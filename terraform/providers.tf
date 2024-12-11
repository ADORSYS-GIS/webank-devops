provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host  = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host  = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}


terraform {
  backend "s3" {
    region  = "eu-central-1"
    key     = "state/webank-eks-cluster-v7"
    encrypt = true
  }
}