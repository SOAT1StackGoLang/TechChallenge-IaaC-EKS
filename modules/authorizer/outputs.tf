# Output Cognito URL
output "cognito_url" {
  value = "https://${aws_cognito_user_pool_domain.auth_domain.domain}.auth.${var.region}.amazoncognito.com"
}

# Output Cognito User Pool ID (needed on Lambdas as and EBV variable)
output "cognito_userpool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

# Output Cognito Client ID (needed on Lambdas as and EBV variable)
output "cognito_client_id" {
  value = aws_cognito_user_pool_client.cognito_appclient.id
}

# Generated API GW endpoint URL that can be used to access the application running on a private ECS Fargate cluster.
output "apigw_endpoint" {
  value       = aws_apigatewayv2_api.api.api_endpoint
  description = "API Gateway Endpoint"
}

