# Nodes in private subnets
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  subnet_ids      = var.private_subnet_ids

  ami_type       = var.ami_type
  disk_size      = var.disk_size
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.pvt_desired_size
    max_size     = var.pvt_max_size
    min_size     = var.pvt_min_size
  }

  tags = {
    Name = var.node_group_name
  }

}

# Nodes in public subnet
#resource "aws_eks_node_group" "public" {
#  cluster_name    = aws_eks_cluster.main.name
#  node_group_name = "${var.node_group_name}-public"
#  node_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
#  subnet_ids      = var.public_subnet_ids

#  ami_type       = var.ami_type
#  disk_size      = var.disk_size
#  instance_types = var.instance_types

#  scaling_config {
#    desired_size = var.pblc_desired_size
#    max_size     = var.pblc_max_size
#    min_size     = var.pblc_min_size
#  }

#  tags = {
#    Name = "${var.node_group_name}-public"
#  }

#}