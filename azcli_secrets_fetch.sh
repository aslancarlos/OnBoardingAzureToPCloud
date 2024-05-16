#!/bin/bash

# Text colors
RED='\033[0;31m'          # Red
GREEN='\033[0;32m'        # Green
YELLOW='\033[0;33m'       # Yellow
BLUE='\033[0;34m'         # Blue
MAGENTA='\033[0;35m'      # Magenta
CYAN='\033[0;36m'         # Cyan
WHITE='\033[0;37m'        # White

# Bold text colors
BOLD_RED='\033[1;31m'     # Bold Red
BOLD_GREEN='\033[1;32m'   # Bold Green
BOLD_YELLOW='\033[1;33m'  # Bold Yellow
BOLD_BLUE='\033[1;34m'    # Bold Blue
BOLD_MAGENTA='\033[1;35m' # Bold Magenta
BOLD_CYAN='\033[1;36m'    # Bold Cyan
BOLD_WHITE='\033[1;37m'   # Bold White

# Reset formatting
RESET='\033[0m'           # Reset to default formatting

## Need to be defined. 
CPM=""

if [[ -z ${CPM} ]]; then
   echo "ERROR: Please add the CPM Server name" 
fi



counter(){
# Counting down 
   # Set the initial countdown value
   countdown=2
   
   # Loop while countdown is greater than 0
   while [ $countdown -gt 0 ]; do
      printf "\rTimer: $countdown seconds remaining"
      sleep 1  # Sleep for 1 second
      countdown=$((countdown - 1))  # Decrement countdown
   done
   echo -e "\n" 
}


# Function check if the safe exist
check_safe_exist() {
  cybr safes list-member -s $1 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
     echo -e "${GREEN}[OK] ${RESET} Exist the safe ${BOLD_GREEN} $1 ${RESET}" 
     return 1
  else 
     echo -e "${RED}[ERROR] ${RESET} No exist safe ${BOLD_RED} $1 ${RESET}" 
     echo "Creating the safe $1"
     counter 
     create_safe $1
     return 0
  fi
}

verify_members_safe(){
   users=("SecretsHub")
   for member in "${users[@]}"; do
      #cybr safe list-members -s $1 | jq '.value[] | select(.memberName == "'${member}'")' > /dev/null 2>&1
      cybr safe list-members -s $1 | grep -i SecretsHub > /dev/null 2>&1
      if [ $? -eq 0 ]; then
         echo -e "${GREEN}[OK] ${RESET} Exist ${member} on safe ${BOLD_GREEN} $1 ${RESET}" 
      else 
         echo -e "${RED}[ERROR] ${RESET} No exist  ${member} on safe ${BOLD_RED} $1 ${RESET}"
         echo -e "${BOLD_RED}Please add the SecretsHub as member on this safe $1${RESET}"
         
      fi
   done
}

#create_member_safe(){
#   cybr safe add-member -s $1 --access-content-without-confirmation --list-accounts --view-safe-members --retrieve-accounts -m 'SecretsHub' -t user 
#   #cybr safe add-member -s $1 --access-content-without-confirmation --list-accounts --view-safe-members --retrieve-accounts -m 'aslan.ramos@cyberark.cloud.1741' -t user 
#}

#Create the safe
create_safe() {
  cybr safes add --cpm $CPM -s $1 -d "Safe created by CyberArk OnBoarding SecretsHub Script" 
  echo "Created $1" 
}

create_account_pcloud(){
  cybr accounts add -s $1 -p SecretsHubPlatform -t password -c $3 --platform-properties "SecretNameInSecretStore=$2" | grep -i id > /dev/null 2>&1
  if [ $? -eq 0 ]; then
         echo -e "${BOLD_GREEN}[OK] ${RESET} Create Secret $2 from $1 Created ${RESET}" 
  else 
         echo -e "${BOLD_GREEN}[FAIL] ${RESET} Create Secret $2 from $1 Created ${RESET}"        
  fi
}

# TAG secrets to SecretsHub know
tag_secrets(){
        echo -e "Retrieving secrets from Resource Group ${BOLD_WHITE}${resource_group}${RESET} -> Key Vault: ${BOLD_WHITE}$vault ${RESET}"
        
        # Get a list of all secrets in the Key Vault
        secrets=$(az keyvault secret list --vault-name $1 --query '[].name' -o tsv)
         for secret in $secrets; do
            az keyvault secret set-attributes --vault-name $1 --name $secret --tags "CyberArk PAM=Privileged Cloud" "CyberArk Safe=$1" "Sourced by CyberArk=True" | grep -i "Sourced by CyberArk"> /dev/null 2>&1          
            if [ $? -eq 0 ]; then
              echo -e "${BOLD_GREEN}[OK] ${RESET}Tag update on secret ${BOLD_CYAN}$secret ${RESET}from vault ${BOLD_YELLOW}$1 ${RESET}" 
            else 
              echo -e "${BOLD_RED}[ERROR] ${RESET}Tag update on secret ${BOLD_CYAN}$secret  ${RESET}from vault ${BOLD_YELLOW}$1 ${RESET}" 
            fi
        done
}

update_recursive(){
    # Iterate over each Key Vault
    for vault in $vaults; do
        echo "Verify if the safe exist on CyberArk PCloud"
        check_safe_exist "${vault}"
        verify_members_safe "${vault}"

        echo -e "Retrieving secrets from Resource Group ${BOLD_WHITE} ${resource_group}${RESET}-> Key Vault: $vault ${RESET}"
        
        # Get a list of all secrets in the Key Vault
        secrets=$(az keyvault secret list --vault-name $vault --query '[].name' -o tsv)
        
        # Iterate over each secret
        for secret in $secrets; do
                       
            # Retrieve the value of the secret
            secret_value=$(az keyvault secret show --vault-name $vault --name $secret --query 'value' -o tsv)
            create_account_pcloud $vault $secret $secret_value 
        done
    done
}
update_vault(){
    # Iterate over each Key Vault
   
        echo "Verify if the safe exist on CyberArk PCloud"
        check_safe_exist "${vault}"
        verify_members_safe "${vault}"

        echo -e "Retrieving secrets from Resource Group ${BOLD_WHITE} ${resource_group}${RESET}-> Key Vault: $vault ${RESET}"
        
        # Get a list of all secrets in the Key Vault
        secrets=$(az keyvault secret list --vault-name $vault --query '[].name' -o tsv)
        
        # Iterate over each secret
        for secret in $secrets; do
                       
            # Retrieve the value of the secret
            secret_value=$(az keyvault secret show --vault-name $vault --name $secret --query 'value' -o tsv)
            create_account_pcloud $vault $secret $secret_value 
        done
}


# CLEAN TERMINAL
clear 
if [ "$1" == "list" ]; then
  if [ "$2" == "" ]; then
   clear
   echo "RESOURCE GROUPS"
   az group list --query '[].name' -o tsv
   exit
  elif [ "$2" == "akv" ]; then
     az keyvault list --resource-group $3 --query '[].name' -o tsv
     exit
  elif [ "$2" == "secrets" ]; then  
     echo "VAULT: $3"
     az keyvault secret list --vault-name $3 --query '[].name' -o tsv
     exit
   fi
fi

if [ "$1" == "akv" ]; then
  if  [ "$2" != "" ]; then
  az keyvault list --resource-group $2 --query '[].name' -o tsv
  exit
  else
  echo "Please add the Resource Group name"
  exit
  fi
fi

if [ "$1" == "" ]; then
   echo -e "You must specify the ${BOLD_RED}ResourceGroup${RESET} and ${BOLD_RED}AKV Name${RESET} to be synchronized to CyberArk Privileged Cloud"
   echo "Example:"
   echo -e "\t$0${BOLD_RED} ResourceGroup AKV_name ${RESET} "
   exit 1
elif [ "$2" == "" ]; then
   echo -e "You must specify the ${BOLD_RED}Vault${RESET} after the ResourceGroup ${BOLD_GREEN}$1${RESET} to be synchronized to CyberArk Privileged Cloud"
   echo "Example:"
   echo -e "\t$0 ${BOLD_GREEN}$1 ${BOLD_BLUE}AKV_name ${RESET} "
   exit 1
fi

vault=$2
resource_group=$1

tag_secrets "${vault}"
update_vault "${vault}"

        

