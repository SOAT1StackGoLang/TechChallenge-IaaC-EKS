# TechChallenge-IaaC

## Descrição

Esse repositório contém os códigos Terraform para deployment da infraestrutura na AWS utilizada na fase5 do techchallenge, bem como provionamento de pods kubernetes da aplicação.

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
   * Acessa a aplicação através do API GW fornecendo o token de autenticação.  O resultado esperado são os dados da categoria "Lanche".  

OBS: É possível que a aplicação ainda esteja sendo inicializada quando o script de verificação é executado.  No caso do script de verificação retornar algo como "message":"Service Unavailable", execute novamente o comando 'terraform apply' para repetir a verificação ou execute o script 'verify.sh'.

Antes de executar o script 'verify.sh', é necessário editá-lo e atualizá-lo com as credenciais do Cognito e a URL do API Gateway


## Fazendo Deployment via ACTION   

O action 'terraform apply' pode ser usado para realizar o deployment da infraestrutura, cluster EKS, bem como o deployment da aplicação no cluster EKS.  Será necessário fornecer as credenciais da nuvem AWS ao executar os script, atarvés do seguinte procedimento:


1. Inicialize o laboratório no AWS Academy
2. Copie as credenciais disponíveis em AWS Details (ver AWS CLI em CLoud Access) que serão pedidos na executação do action
3. No repositório do Git Hub, execute o action 'Terraform Apply'. Ao executar esse action serão pedidas as credenciais AWS obtidas anteriormente.
4. Lembre-se de executar o action 'Terrafrom Destroy' ao final dos testes.  Ao executar esse action serão pedidas novamente as credenciais AWS obtidas anteriormente.



## Testando na máquina local

1. Inicialize o laboratório no AWS Academy
2. Copie as credenciais disponíveis em AWS Details (ver AWS CLI em CLoud Access) para o arquivo ~/.aws/credentials da sua máquina
3. Execute o script ./aws-setup.sh para inicializar o backend S3 (que será usado pelo Terraform) e configurar o repositório GIT com as credenciais AWS.
4. Execute o comando 'terraform init' informado ao final da execução do script executado no passo anterior.
5. Execute 'terraform apply' para realizar as tarefas descritas acima
6. Execute o seguinte comando para configurar as credenciais do cluster EKS na sua máquina e poder executar comandos com kubectl:
      aws eks --region us-east-1 update-kubeconfig --name techchallenge
7. Lembre-se de executar 'terraform destroy' ao final dos testes





