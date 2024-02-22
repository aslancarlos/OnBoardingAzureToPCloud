#!/bin/bash

## FIRST STEP DISCOVER , add some arguments to solve it. but its ok


## GET ALL SECRETS AVAILABLE 
#  az keyvault secret list --vault-name iwt2023mx --query [].name -o tsv

# Declare K:V

## Show the value

# az keyvault secret show --vault-name iwt2023mx  --name "Secrets-Hub-Accounts-oxxo-testplaintext" --query "value"

# validate if the AZURE CLI is installed

# REFACT: could be better to show which is missing.

if ! [ `which az` ] || ! [ `which jq` ]; then 
  clear
  echo  "ERR: Please check your Azure Cli Installation or AZ Command Path"
  exit 1

fi 


# Generate file to work, all AKV accessible by this account

AKV_LIST_FILE="avk_list.json"

az keyvault list > $AKV_LIST_FILE

if ! [ -f $AKV_LIST_FILE ]; then
  echo "ERR: Cannot access the AKV, check you credentials"
fi


# Check the length ?

AKV_LENGTH=`jq length ${AKV_LIST_FILE}`

AKV_LENGTH=$(expr $AKV_LENGTH - 1)

for i in $(seq 0 $AKV_LENGTH); do
  vault=`jq ".[$i] | .type" $AKV_LIST_FILE`
  if ! [[ $vault == *"vaults"* ]]; then
     continue
  fi

  name=`jq ".[$i] | .name" $AKV_LIST_FILE`
  location=`jq ".[$i] | .location" $AKV_LIST_FILE`
  resource=`jq ".[$i] | .resourceGroup" $AKV_LIST_FILE`

 echo $name 

done



#### Porfa, cambear nomes IWT2023MX en todas las lineas, com nome de AKV
#### tuve erros como variaveis.

FILEEXPORTED="iwt2023.csv"
NAME="iwt2023mx"

TOTAL=`az keyvault secret list --vault-name iwt2023mx | jq " length"`

echo "-- Recovering total of $TOTAL secrets from $NAME"
echo "userName,Secret Name In Target,safeName,platformID,secret,automaticManagementEnabled,manualManagementReason" > $FILEEXPORTED
for i in `cat teste`; do 
   TOTAL=$(expr $TOTAL - 1)
   echo "Fetching [$i] - left $TOTAL"
   passwd=`az keyvault secret show --vault-name iwt2023mx  --name $i --query "value"`
   echo "$i,$i,Secrets Hub Accounts,SecretsHub Platform,$passwd,FALSE,Imported by CyberArk OnBoarding" >> $FILEEXPORTED
done


PASSWDGEN=`openssl rand -base64 16`
echo ":: Encrypting the file $FILEEXPORTED"

openssl enc -pbkdf2 -salt -in $FILEEXPORTED -out $FILEEXPORTED.enc -k $PASSWDGEN
echo ":: removing the clean text file"
rm -rf $FILEEXPORTED

echo "!! The secrets now is encrypted, save this password"
echo $PASSWDGEN
echo "!! The file is $FILEEXPORTED.enc"

echo "!! Example: Open the file: "
echo "openssl enc -salt -in $FILEEXPORTED.enc -out $FILEEXPORTED.clear -k $PASSWDGEN"

# Clean up 
#rm -rf $AKV_LIST_FILE