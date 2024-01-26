# TechChallenge-IaaC

## Descrição

Esse repositório contém os códigos Terraform para deployment da infraestrutura na AWS utilizada na fase4 do techchallenge, bem como provionamento de pods kubernetes da aplicação.

Todo provisionamento foi feito asssumindo-se que AWS Academy está sendo utilizado.  AWS Academy não permite a criação de IAM roles ou qualquer outro recurso relacioado a AWS IAM. Sendo assim, em todos os módulos é utilizado o role LabRole pre-existente na AWS Academy.

As seguintes tarefas são realizadas por esse código Terradorm:

* Através do módulo vpc: Provisionamento da infra da rede (VPC, subnet, Internet Gateway, route table e NAT)
* Através do módulo rds: Provisionamento da instância de database RDS postgres que será usado pela aplicação
* Através do módulo elasticache: Provisionamento da instância de database Elasticache REDIS que será usado pela aplicação
* Através do módulo eks: Provisionamento do cluster EKS
* Através do módulo app: Provisionamento dos manifestos K8s relacionados à aplicação (secrets, namespace, deployments e services) 
* Através do módulo authorizer: Provisionamento dos recursos necessário para autorização e acesso à aplicação, ou seja, Cognito, lambda de autorização e Application Gateway integrado com serviço de load balancer da aplicação.
* Verificação de funcionamento: as seguintes tarefas são executadas (ver verify.tf):
   * obtém token de autenticação no Cognito com usuário teste 
   * Acessa a aplicação através do API GW sem fornecer o Token.  O resultado esperado é "message":"Forbidden"
   * Acessa a aplicação através do API GW fornecendo o token de autenticação.  O resultado esperado é a lista de categorias existentes no sistema.  

OBS: É possível que a aplicação ainda esteja sendo inicializada quando o script de verificação é executado.  No caso do script de verificação retornar algo como "message":"Service Unavailable", execute novamente o comando 'terraform apply' para repetir a verificação.


## Pré-requisitos

Execute os seguintes passoa para inializar o backend Terraform e configurar as credenciais de acesso à AWS Academy:`

1. Inicialize o laboratório no AWS Academy
2. Copie as credenciais disponíveis em AWS Details (ver AWS CLI em CLoud Access) para o arquivo ~/.aws/credentials da sua máquina
3. Execute o script ./aws-setup.sh para inicializar o backend S3 (que será usado pelo Terraform) e configurar o repositório GIT com as credenciais AWS.

## Testando na máquina local

1. Execute o comando 'terraform init' informado ao final da execução do script executado no passo anterior.
2. Execute 'terraform apply' para realizar as tarefas descritas acima
3. Execute o seguinte comando para configurar as credenciais do cluster EKS na sua máquina e poder executar comandos com kubectl:
      aws eks --region us-east-1 update-kubeconfig --name techchallenge
4. Lembre-se de executar 'terraform destroy' ao final dos testes





