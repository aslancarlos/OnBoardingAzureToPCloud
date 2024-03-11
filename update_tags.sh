#!/bin/bash


## This script could run many times, will update the tags already exist or add what are missing, but will keep just the tags we have here.
# Key Vault from Azure 
KEY_VAULT_NAME="iwt2023mx"
# Add the name of Safe on CyberArk Privileged Cloud where the SH account will be Onboading. 
NEWSAFE="oxxo"

# The tags required by CyberArk Secrets Hub to manage this accounts.
TAG_CYBERARK_PAM="CyberArk PAM=Privileged Cloud"
TAG_CYBERARK_SAFE="CyberARk Safe=$NEWSAFE"
TAG_CYBERARK_SOURCE="Sourced by CyberArk=True"

if [ -z "$KEY_VAULT_NAME" ]; then
  echo "ERROR:Please edit this file add the KEY_VAULT_NAME, the AKV Secrets Vault name where will be updated the TAGS "
  return 1
fi

if [ -z "$NEWSAFE" ]; then
  echo "ERROR:Please edit this file add the NEWSAFE, SAFE where the account will be created or are created on CyberArk Privileged Cloud"
  return 1
fi


secrets=$(az keyvault secret list --vault-name $KEY_VAULT_NAME)



## CHECK THE SECRET IF MANAGED BY CYBERARK 
## az keyvault secret list --vault-name iwt2023mx | jq '.[].tags | keys[] == "CyberArk PAM" '


for secret in $(echo $secrets |  jq -r '.[].name'); do 
    az keyvault secret set-attributes --vault-name $KEY_VAULT_NAME --name $secret --tags "CyberArk PAM=Privileged Cloud" "CyberArk Safe=$NEWSAFE" "Sourced by CyberArk=True"
done