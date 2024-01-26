output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}


output "cluster_ca_certificate" {
  description = "CA Certificate for EKS cluster"
  value       = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
}

output "cluster_token" {
  description = "Token EKS cluster"
  value       = data.aws_eks_cluster_auth.main.token
}

