#!/bin/bash


# This script is the first step to onboarding the accounts.
# Set the tags required by CyberArk SecretsHub

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

clear
echo -e "Set the required Tags on ${BLUE}Azure AKV ${RESET}for ${GREEN}CyberArk Secrets HUB${RESET}"
# Get a list of all resource groups
resource_groups=$(az group list --query '[].name' -o tsv)

# Iterate over each resource group
for resource_group in $resource_groups; do
    
    # Get a list of all Key Vaults in the resource group
    vaults=$(az keyvault list --resource-group $resource_group --query '[].name' -o tsv)
        
    # Iterate over each Key Vault
    for vault in $vaults; do
 
        echo -e "Retrieving secrets from Resource Group ${BOLD_WHITE} ${resource_group}${RESET}-> Key Vault: ${BOLD_WHITE}$vault ${RESET}"
        
        # Get a list of all secrets in the Key Vault
        secrets=$(az keyvault secret list --vault-name $vault --query '[].name' -o tsv)
         for secret in $secrets; do
            az keyvault secret set-attributes --vault-name $vault --name $secret --tags "CyberArk PAM=Privileged Cloud" "CyberArk Safe=$vault" "Sourced by CyberArk=True" | grep -i "Sourced by CyberArk"> /dev/null 2>&1          
            if [ $? -eq 0 ]; then
              echo -e "${BOLD_GREEN}[OK] ${RESET}Tag update on secret ${BOLD_CYAN}$secret ${RESET}from vault ${BOLD_YELLOW}$vault ${RESET}" 
            else 
              echo -e "${BOLD_RED}[ERROR] ${RESET} Tag update on secret ${BOLD_CYAN}$secret  ${RESET}from vault ${BOLD_YELLOW}$vault ${RESET}" 
            fi
        done
    done
done

## CHECK THE SECRET IF MANAGED BY CYBERARK 
## az keyvault secret list --vault-name iwt2023mx | jq '.[].tags | keys[] == "CyberArk PAM" '
