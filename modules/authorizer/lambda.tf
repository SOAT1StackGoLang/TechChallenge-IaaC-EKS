# Get AWS caller identity
data "aws_caller_identity" "current" {}

#-----------------------------------------------------------------------------------------------
#   Lambda Config
#-----------------------------------------------------------------------------------------------

# Provide permission to API GW to Invoke Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Download ZIP file that will be used to create lambda
resource "null_resource" "download_file" {
  provisioner "local-exec" {
    command = "curl -s -L https://github.com/SOAT1StackGoLang/oAuth2Authorizer/releases/download/latest/bundle.zip -o ${path.module}/bundle.zip"
  }
  # always run
  triggers = {
    always_run = "${timestamp()}"
  }
}


# Create Lambda function
resource "aws_lambda_function" "authorizer_lambda" {
  function_name = "${var.project_name}_oAuth2Authorizer"
  role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  runtime       = "nodejs16.x"
  filename      = "${path.module}/bundle.zip"
  #source_code_hash = filebase64sha256("${path.module}/bundle.zip")
  handler       = "index.handler"
  architectures = ["x86_64"]
  environment {
    variables = {
      CLIENT_ID    = aws_cognito_user_pool_client.cognito_appclient.id
      USER_POOL_ID = aws_cognito_user_pool.user_pool.id
    }
  }
  depends_on = [aws_cognito_user_pool_client.cognito_appclient,
    aws_cognito_user_pool.user_pool,
    null_resource.download_file
  ]

}




