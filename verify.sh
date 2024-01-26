#!/bin/bash

cognito__user_pool_id="us-east-1_RbpQ7DOCJ"
cognito_appclient_id="429l0nbjc48e71h21nt90hbq4m" 
cognito_username="11122233300"
cognito_password="F@ap1234"
api_gw_url="https://zzzz3tnga7.execute-api.us-east-1.amazonaws.com"

token=$(aws cognito-idp admin-initiate-auth --user-pool-id $cognito__user_pool_id \
  --client-id $cognito_appclient_id \
  --auth-flow ADMIN_NO_SRP_AUTH \
  --auth-parameters USERNAME=$cognito_username,PASSWORD=$cognito_password \
  | jq -r '.AuthenticationResult.AccessToken')


echo -e "\n-------------------------------TOKEN------------------------------------------" 
echo "$token" 

#test_endpoint="$api_gw_url/v1/categories/all"
test_endpoint="$api_gw_url/test"

test_body='{
  "limit": 10,
  "offset": 0,
  "user_id": "123e4567-e89b-12d3-a456-426614174000"
  }'

echo -e "\n-------------------------TEST WITHOUT TOKEN------------------------------------"  

test_without_token="curl --location $test_endpoint -s \
  --header 'Content-Type: application/json' \
  --data '$test_body'"

eval "$test_without_token" 


echo -e "\n-------------------------TEST WITH TOKEN-------------------------------------" 

test_with_token="curl -X GET --location $test_endpoint -s \
  --header 'Authorization: $token'  \
  --header 'Content-Type: application/json' \
  --data '$test_body'"

eval "$test_with_token" 

