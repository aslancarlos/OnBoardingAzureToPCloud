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
     echo -e "${GREEN}[OK] ${RESET} Exist ${BOLD_GREEN} $1 ${RESET}" 
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
      cybr safe list-members -s $1 | jq '.value[] | select(.memberName == "'${member}'")' > /dev/null 2>&1
      if [ $? -eq 0 ]; then
         echo -e "${GREEN}[OK] ${RESET} Exist ${member} on ${BOLD_GREEN} $1 ${RESET}" 
      else 
         echo -e "${RED}[ERROR] ${RESET} No exist safe ${member} on  ${BOLD_RED} $1 ${RESET}"
         counter
         create_member_safe
      fi
   done
}

create_member_safe(){
   cybr safe add-member -s $1 --access-content-without-confirmation --list-accounts --view-safe-members --retrieve-accounts -m 'SecretsHub' -t user > /dev/null 2>&1
}

#Create the safe
create_safe() {
  cybr safes add -s $1 -d "Safe created by CyberArk OnBoarding SecretsHub Script"   
  echo "Created $1" 
}

# CLEAN TERMINAL
clear 

echo -e "Onboarding account from ${BLUE} Azure AKV ${RESET} to ${GREEN} CyberArk Secrets HUB ${RESET}"

# Get a list of all resource groups
resource_groups=$(az group list --query '[].name' -o tsv)

# Iterate over each resource group
for resource_group in $resource_groups; do
    echo "Retrieving secrets from resource group: $resource_group"
    
    # Get a list of all Key Vaults in the resource group
    vaults=$(az keyvault list --resource-group $resource_group --query '[].name' -o tsv)
        
    # Iterate over each Key Vault
    for vault in $vaults; do
        echo "Verify if the safe exist on CyberArk PCloud"
        check_safe_exist "${vault}"
        verify_members_safe "${vault}"

        echo "Retrieving secrets from Resource Group ${resource_group} -> Key Vault: $vault"
        
        # Get a list of all secrets in the Key Vault
        secrets=$(az keyvault secret list --vault-name $vault --query '[].name' -o tsv)
        
        # Iterate over each secret
        for secret in $secrets; do
            echo "Secret Name: $secret"
            echo "Vault Name: $vault"
            
            # Retrieve the value of the secret
            secret_value=$(az keyvault secret show --vault-name $vault --name $secret --query 'value' -o tsv)
            echo "Secret Value: $secret_value"
            
            # Add your logic here to handle the secret value if needed...
        done
    done
done

