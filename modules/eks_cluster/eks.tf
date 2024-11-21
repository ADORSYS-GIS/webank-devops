resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceControllerPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_cluster" "webank" {
  name     = "webank-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = flatten([
      module.subnets.private_subnet_ids,
      module.subnets.public_subnet_ids,
    ])
}


  tags = {
    "Name"              = "webank-cluster"
    "environment"       = "production"
    "kubernetes.io/cluster/webank" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSVPCResourceControllerPolicy
  ]
}

module "subnets"{
  source = "../vpc/Subnets"
}