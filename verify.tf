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

      test_endpoint="${module.authorizer.apigw_endpoint}/category/9764bd96-3bcf-11ee-be56-0242ac120002"
      #test_endpoint="${module.authorizer.apigw_endpoint}/category/all"

      echo  "\n-------------------------TEST WITHOUT TOKEN------------------------------------"  >> /tmp/verification.txt

      test_without_token="curl -X GET --location $test_endpoint -s \
        --header 'Content-Type: application/json'"

      eval "$test_without_token" >> /tmp/verification.txt 


      echo  "\n-------------------------TEST WITH TOKEN-------------------------------------" >> /tmp/verification.txt

      test_with_token="curl -X GET --location $test_endpoint -s \
        --header 'Authorization: $token'  \
        --header 'Content-Type: application/json'"

      eval "$test_with_token" >> /tmp/verification.txt

      echo  "\n-------------------------OBSERVACAO-----------------------------------------------"  >> /tmp/verification.txt
      echo  " O esperado é o que teste sem o token retorne 'Forbidden' e o teste com o token "  >> /tmp/verification.txt
      echo  " retorne os dados da categoria.  Caso o teste com o token tenha retornado 'System "  >> /tmp/verification.txt
      echo  " Unavailable', possivelemnte não houve tempo para a total inicialização do sistema."  >> /tmp/verification.txt
      echo  " Nesse caso, repita novamente a verificação executando o script verify.sh."  >> /tmp/verification.txt
      echo  " Antes da execução do script verify.sh, edite o script para atualizar as credenciais"  >> /tmp/verification.txt
      echo  " do Cognito e a URL do API GW com os dados fornecidos abaixo"  >> /tmp/verification.txt
      echo  "-----------------------------------------------------------------------------------\n"  >> /tmp/verification.txt
      echo "Orders Swagger URL: ${module.authorizer.apigw_endpoint}/swagger/index.html" >> /tmp/verification.txt
      echo "Production Swagger URL: ${module.authorizer.apigw_endpoint}/production/swagger/index.html" >> /tmp/verification.txt
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


