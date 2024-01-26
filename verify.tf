##################
## Verification ##
##################
# Define the null_resource to run the curl command and make sure that is the last thing that terraform will run
resource "null_resource" "Verification" {
  # Run the local-exec provisioner after the null_resource is created
  provisioner "local-exec" {
    command = <<EOT
      token=$(aws cognito-idp admin-initiate-auth --user-pool-id ${module.authorizer.cognito_userpool_id} \
        --client-id ${module.authorizer.cognito_client_id} \
        --auth-flow ADMIN_NO_SRP_AUTH \
        --auth-parameters USERNAME=${var.cognito_test_user.username},PASSWORD=${var.cognito_test_user.password} \
        | jq -r '.AuthenticationResult.AccessToken')


      echo  "\n" > /tmp/verification.txt
      #echo  "\n-------------------------------TOKEN------------------------------------------" >> /tmp/verification.txt
      #echo "$token" >> /tmp/verification.txt

      test_endpoint="${module.authorizer.apigw_endpoint}/v1/categories/all"

      test_body='{
        "limit": 10,
        "offset": 0,
        "user_id": "123e4567-e89b-12d3-a456-426614174000"
        }'

      echo  "\n-------------------------TEST WITHOUT TOKEN------------------------------------"  >> /tmp/verification.txt

      test_without_token="curl --location $test_endpoint -s \
        --header 'Content-Type: application/json' \
        --data '$test_body'"

      eval "$test_without_token" >> /tmp/verification.txt 


      echo  "\n-------------------------TEST WITH TOKEN-------------------------------------" >> /tmp/verification.txt

      test_with_token="curl --location $test_endpoint -s \
        --header 'Authorization: $token'  \
        --header 'Content-Type: application/json' \
        --data '$test_body'"

      eval "$test_with_token" >> /tmp/verification.txt
    EOT
  }
  depends_on = [module.authorizer]

  # always run the provisioner
  triggers = {
    always_run = "${timestamp()}"
  }
}

## Read the output file from the curl command and print it out
data "local_file" "VerificationOutput" {
  filename   = "/tmp/verification.txt"
  depends_on = [null_resource.Verification]
}

output "VerificationOutput" {
  value     = data.local_file.VerificationOutput.content
  sensitive = false
}


