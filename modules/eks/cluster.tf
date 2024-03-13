# Get AWS caller identity
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "main" {
  name = var.eks_cluster_name
}

resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    subnet_ids              = var.eks_cluster_subnet_ids
  }
}

