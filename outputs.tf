#--------------------------------------------------------------------------
# From Module VPC
#--------------------------------------------------------------------------

#output vpc_arn {
#  value = module.vpc_for_eks.vpc_arn
#}

#output vpc_id {
#  value = module.vpc_for_eks.vpc_id
#}

#output private_subnet_ids {
#  value = module.vpc_for_eks.private_subnet_ids
#}

#output public_subnet_ids {
#  value = module.vpc_for_eks.public_subnet_ids
#}

#output control_plane_sg_security_group_id {
#  value = module.vpc_for_eks.control_plane_sg_security_group_id
#}

#output data_plane_sg_security_group_id {
#  value = module.vpc_for_eks.data_plane_sg_security_group_id
#}

#output public_subnet_security_group_id {
#  value = module.vpc_for_eks.public_subnet_security_group_id
#}


#--------------------------------------------------------------------------
# From Moduleo EKS
#--------------------------------------------------------------------------

#output "cluster_endpoint" {
#  description = "Endpoint for EKS control plane"
#  value       = module.eks_cluster.cluster_endpoint
#}

#output "cluster_ca_certificate" {
#  description = "CA Certificate for EKS cluster"
#  value       = module.eks_cluster.cluster_ca_certificate
#}

#output "cluster_token" {
#  description = "Token EKS cluster"
#  value       = module.eks_cluster.cluster_token
#  sensitive   = true
#}


#--------------------------------------------------------------------------
# From Module authorization
#--------------------------------------------------------------------------

# Output Cognito URL
output "cognito_url" {
  value = module.authorizer.cognito_url
}

# Output Cognito User Pool ID (needed on Lambdas as and EBV variable)
output "cognito_userpool_id" {
  value = module.authorizer.cognito_userpool_id
}

# Output Cognito Client ID (needed on Lambdas as and EBV variable)
output "cognito_client_id" {
  value = module.authorizer.cognito_client_id
}

# Generated API GW endpoint URL that can be used to access the application running on a private ECS Fargate cluster.
output "apigw_endpoint" {
  value = module.authorizer.apigw_endpoint
}


#--------------------------------------------------------------------------
# From Module Elasticache
#--------------------------------------------------------------------------

output "primary_endpoint_address" {
  value = module.elasticache.primary_endpoint_address
}

output "reader_endpoint_address" {
  value = module.elasticache.reader_endpoint_address
}