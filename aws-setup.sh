#!/bin/bash
# this script will be used to setup the aws account for the terraform deployer
# run on the local machine with the aws cli installed and configured with the root/admin account
# create the user terraform-deployer and give it the correct permissions

# prerequisites
# aws cli installed and configured with the root/admin account
# github cli installed and configured with the root/admin account
# jq installed

# check if the aws cli is installed
if ! command -v aws &> /dev/null
then
    echo "aws cli could not be found"
    exit
fi

# check if the github cli is installed
if ! command -v gh &> /dev/null
then
    echo "github cli could not be found"
    exit
fi

# check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found"
    exit
fi

# check if the aws cli is configured
if ! aws sts get-caller-identity &> /dev/null
then
    echo "aws cli is not configured"
    exit
fi

# check if the github cli is configured
if ! gh auth status  -h github.com &> /dev/null
then
    echo "github cli is not configured"
    exit
fi

## set aws cli global configs
# set the default output to json temporarly using env variables
export AWS_DEFAULT_OUTPUT=json

# get access key and secret access key from credentials file
access_key_cmd=$(cat ~/.aws/credentials | grep aws_access_key)
access_key_id=$(echo $access_key_cmd | sed 's/.*key_id=\(.*\)/\1/')
secret_access_key_cmd=$(cat ~/.aws/credentials | grep aws_secret_access_key)
secret_access_key=$(echo $secret_access_key_cmd | sed 's/.*secret_access_key=\(.*\)/\1/')
session_token_cmd=$(cat ~/.aws/credentials | grep aws_session_token)
session_token=$(echo $session_token_cmd | sed 's/.*key_id=\(.*\)/\1/')

## using github cli to create the variables for the github repo secrets for the access key and secret key to current repo
# create the secret for the access key
# get the current repo name with https://HOST/OWNER/REPO
repo_url=$(git config --get remote.origin.url)
repo_name=$(echo $repo_url | sed 's/.*github.com\/\(.*\)\.git/\1/')


## WARNING ##
## Only run this gh command if you want to change the default AWS ACCOUNT for the repo
## Uncomment the following lines to change the default AWS ACCOUNT for the repo
gh secret set AWS_ACCESS_KEY_ID -b $access_key_id --repo=github.com/$repo_name
gh secret set AWS_SECRET_ACCESS_KEY -b $secret_access_key --repo=github.com/$repo_name
gh secret set AWS_SESSION_TOKEN -b $session_token --repo=github.com/$repo_name
## WARNING ##

# echo the access key and secret key env variables
#echo "Save the following env variable on a secure place as they will only be shown once"
#echo "export AWS_ACCESS_KEY_ID=$access_key_id"
#echo "export AWS_SECRET_ACCESS_KEY=$secret_access_key"

# test the access key and secret key
echo "testing the access key and secret key"
#export AWS_ACCESS_KEY_ID=$access_key_id
#export AWS_SECRET_ACCESS_KEY=$secret_access_key
aws configure list
aws sts get-caller-identity

## Create the S3 bucket that will hold the terraform state
# create the bucket
aws s3api create-bucket --bucket s1sg-tc-terraform-state-bucket-fase4 --region us-east-1
#account_id=$(aws sts get-caller-identity --query 'Account' --output text)
#aws s3api create-bucket --bucket s1sg-tc-terraform-state-bucket-$account_id --region us-east-1

echo "run the following command to initiate terraform"
echo "terraform init -backend-config=\"bucket=s1sg-tc-terraform-state-bucket-fase4\" -backend-config=\"key=terraform.tfstate\" -backend-config=\"region=us-east-1\" -reconfigure"
#echo "terraform init -backend-config=\"bucket=s1sg-tc-terraform-state-bucket-$account_id\" -backend-config=\"key=terraform.tfstate\" -backend-config=\"region=us-east-1\""

# Cleanup and delete the user
# aws iam list-access-keys --user-name terraform-deployer
# aws iam delete-access-key --access-key-id $(aws iam list-access-keys --user-name terraform-deployer --query 'AccessKeyMetadata[0].AccessKeyId' --output text) --user-name terraform-deployer
# aws iam remove-user-from-group --user-name terraform-deployer --group-name terraform-deployer-group
# aws iam delete-user --user-name terraform-deployer
# aws iam delete-group --group-name terraform-deployer-group
# gh secret delete AWS_ACCESS_KEY_ID --repo=github.com/$repo_name
# gh secret delete AWS_SECRET_ACCESS_KEY --repo=github.com/$repo_name
# aws s3api delete-bucket --bucket s1sg-tc-terraform-state-bucket-$account_id --region us-east-1
