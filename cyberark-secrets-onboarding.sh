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


############################################################
######################## REQUIRED #########################
# Please define which CPM Server will be used on CyberArk PAM Safe
CPM=""

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
  ark exec pcloud safes safe -si $1 > /dev/null 2>&1
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
  member="SecretsHub"
  #cybr safe list-members -s $1 | grep -i SecretsHub > /dev/null 2>&1
  ark exec pcloud safes list-safe-members-by -si $1 -s SecretsHub > /dev/null 2>&1
  if [ $? -eq 0 ]; then
     echo -e "${GREEN}[OK] ${RESET} Exist ${member} on safe ${BOLD_GREEN} $1 ${RESET}" 
  else 
     echo -e "${RED}[ERROR] ${RESET} No exist  ${member} on safe ${BOLD_RED} $1 ${RESET}"
     echo -e "${BOLD_RED}Please add the SecretsHub as member on this safe $1${RESET}"
  fi
}


# To remove
#create_member_safe(){
#   cybr safe add-member -s $1 --access-content-without-confirmation --list-accounts --view-safe-members --retrieve-accounts -m 'SecretsHub' -t user 
#   #cybr safe add-member -s $1 --access-content-without-confirmation --list-accounts --view-safe-members --retrieve-accounts -m 'aslan.ramos@cyberark.cloud.1741' -t user 
#}

#Create the safe
create_safe() {
  #cybr safes add --cpm $CPM -s $1 -d "Safe created by CyberArk OnBoarding SecretsHub Script" 
  ark exec pcloud safes add-safe -sn $1 -d "Created by ARK CLI for Azure OnBoarding" -mc $CPM > /dev/null 2>&1
  if [ $? -eq 0 ]; then
     echo -e "${GREEN}[OK] ${RESET} Created Safe $1 ${RESET}" 
  else 
     echo -e "${RED}[ERROR] ${RESET} Cannot create safe:${BOLD_RED} $1 ${RESET}"
     exit 1
  fi
}

create_account_pcloud(){
  safe=$1
  secretname=$2
  secret=$3
  #cybr accounts add -s $1 -p SecretsHubPlatform -t password -c $3 --platform-properties "SecretNameInSecretStore=$2" | grep -i id > /dev/null 2>&1
  ark exec pcloud accounts add-account -sn $safe -n $secretname -un $secretname -pi SecretsHubPlatform -st password -s $secret -pap AKVName=$safename -pap SecretNameInSecretStore=$secretname 
  if [ $? -eq 0 ]; then
         echo -e "${BOLD_GREEN}[OK]${RESET} Create Secret $2 from $1 Created ${RESET}" 
  else 
         echo -e "${BOLD_GREEN}[FAIL]${RESET} Create Secret $2 from $1 Created ${RESET}"        
  fi
}

# TAG secrets to SecretsHub know
tag_secrets(){
        echo -e "[+] Retrieving secrets from Resource Group ${BOLD_WHITE}$1${RESET} -> Key Vault: ${BOLD_WHITE}$2 ${RESET}"
        
        # Get a list of all secrets in the Key Vault
        secrets=$(az keyvault secret list --vault-name $2 --query '[].name' -o tsv)
         for secret in $secrets; do
            az keyvault secret set-attributes --vault-name $2 --name $secret --tags "CyberArk PAM=Privileged Cloud" "CyberArk Safe=$1" "Sourced by CyberArk=True" "CyberArk Account=$secret" | grep -i "Sourced by CyberArk"> /dev/null 2>&1          
            if [ $? -eq 0 ]; then
              echo -e "${BOLD_GREEN}[OK] ${RESET}Tag update on secret ${BOLD_CYAN}$secret ${RESET}from key vault ${BOLD_YELLOW}$2 ${RESET}" 
            else 
              echo -e "${BOLD_RED}[ERROR] ${RESET}Tag update on secret ${BOLD_CYAN}$secret  ${RESET}from key vault ${BOLD_YELLOW}$2 ${RESET}" 
            fi
        done
}

update_recursive(){
    echo "DISABLED update_recursive"
    exit 1
    # Iterate over each Key Vault
    for vault in $vaults; do
        echo "[-] Verify if the safe exist on CyberArk PCloud"
        check_safe_exist "${vault}"
        verify_members_safe "${vault}"

        echo -e "[+] Retrieving secrets from Resource Group ${BOLD_WHITE} ${resource_group}${RESET}-> Key Vault: $vault ${RESET}"
        
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

add_sh_member_vault(){
   echo "[-] Verify if the safe exist on CyberArk PCloud"
   member="SecretsHub"
   #cybr safe list-members -s $1 | grep -i SecretsHub > /dev/null 2>&1
   ark exec pcloud safes add-safe-member  --permission-set custom -mn $member -si $1 -mt User -npua -pra  -pla -pvsm -pawc > /dev/null 2>&1
   if [ $? -eq 0 ]; then
      echo -e "${GREEN}[OK]${RESET} Added ${member} on safe:${BOLD_GREEN} $1 ${RESET}"
   else
      echo -e "${RED}[ERROR] ${RESET} Already exist ${member} on safe ${BOLD_RED} $1 ${RESET}"
   fi
}
update_vault(){
    # Iterate over each Key Vault
   
        echo "[-] Verify if the safe exist on CyberArk PCloud"
        check_safe_exist "$2"
        verify_members_safe "$2"
	add_sh_member_vault "$2"

        echo -e "[AZURE] Retrieving secrets from Resource Group ${BOLD_WHITE} $1 ${RESET}-> Key Vault: $2 ${RESET}"
        
        # Get a list of all secrets in the Key Vault
        secrets=$(az keyvault secret list --vault-name $2 --query '[].name' -o tsv)
        
        # Iterate over each secret
        for secret in $secrets; do
                       
            # Retrieve the value of the secret
            secret_value=$(az keyvault secret show --vault-name $2 --name $secret --query 'value' -o tsv)
            create_account_pcloud $2 $secret $secret_value 
        done
}

check_az() {
  if ! command -v "az" &> /dev/null; then
    echo -e "${BOLD_RED} ERROR: AZCLI is not installed. Please install it to proceed.${RESET}\n"
    echo -e "${BOLD_YELLOW}!!! Please follow this procedure:${YELLOW} https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt ${RESET}"
    exit 1
  fi
}


check_cybr() {
  if ! command -v "ark" &> /dev/null; then
    echo -e "${BOLD_RED} ERROR: ARK CLI is not installed. Please install it to proceed.${RESET}\n"
    echo -e "${BOLD_YELLOW}!!! Please follow this procedure: ${YELLOW}https://github.com/cyberark/ark-sdk-python/tree/main ${RESET}"
    exit 1
  fi
}

log_error(){
   echo -e "${BOLD_RED}ERROR:${RED} $1 ${RESET}\n"
   show_help
   exit 1
}


show_help() {
  echo "Usage: $0 <command> [options]"
  echo
  echo "Commands:"
  echo "  list [subscriptions|resource|akv|secrets|tag]   Perform listing operations for subscriptions, resource groups, key vaults, or secrets."
  echo "    subscriptions                                 List all subscriptions your account can access."
  echo "    resource                                      List all resource groups in the current subscription."
  echo "    akv <resource-group>                          List all key vaults within the specified resource group."
  echo "    secrets <vault-name>                          List all secrets stored in the specified key vault."
  echo "    tag <resource-group> <vault-name>             Tag all secrets in the specified key vault with SecretsHub tags."
  echo
  echo "  set <subscription-id>                           Change the active subscription to the specified subscription ID."
  echo
  echo "  akv <resource-group>                            List all key vaults in the specified resource group."
  echo
  echo "  tag <resource-group> <vault-name>               Apply tags to all secrets in the specified key vault."
  echo
  echo "  onboard <resource-group> <vault-name>           Create the Vault and accounts on CyberArk PCLOUD."
  echo
  echo "Examples:"
  echo "  $0 list subscriptions                           List all subscriptions available to your account."
  echo "  $0 list resource                                List all resource groups in the current subscription."
  echo "  $0 list akv <resource-group>                    List key vaults within a specific resource group."
  echo "  $0 list secrets <vault-name>                    List secrets stored in a specific key vault."
  echo "  $0 set <subscription-id>                        Change to a specific subscription by its ID."
  echo "  $0 akv <resource-group>                         List all key vaults in a specific resource group."
  echo "  $0 tag <resource-group> <vault-name>            Tag all secrets in a specified key vault."
  echo "  $0 onboard <resource-group> <vault-name>        Create the Vault and accounts on CyberArk PCLOUD."
  echo
  echo "Note:"
  echo "  Ensure all required parameters are provided for each command."
  echo "  Use the 'list' command to identify resources and prepare for further operations."
  exit 1
}


# Check if the required software are installed
check_az
check_cybr


# To create a safe, it is required to define the CPM Server
# Please check on your PCLOUD tenant which one will be used
if [[ -z "${CPM}" ]]; then
    echo -e "${BOLD_RED} ERROR: Missing the CPM Server name ${RESET}\n\n"
    echo -e "${BOLD_YELLOW} !!! Please edit $0 and add the CPM server name to the CPM variable.${RESET}" 
    exit 1
fi



if [ -z "$1" ]; then
  clear
  show_help
fi






# CLEAN TERMINAL
#clear 

# Processa os comandos
case "$1" in
  list)
    case "$2" in
      subscriptions)
	username=$(az account show -o json | jq -r '.user.name')
        echo -e "${BOLD_GREEN}Logged as: ${BOLD_YELLOW}$username ${RESET}"
        az account list --query '[].{Name:name, SubscriptionId:id, IsDefault:isDefault}' -o table
        ;;
      resource)
        echo -e "${BOLD_GREEN}Resource Groups: ${RESET}\n"
	az group list --query '[].{Name:name, Location:location}' -o table
        ;;
      akv)
        if [ -z "$3" ]; then
          log_error "Please specify the resource group name."
        fi
        echo -e "${BOLD_WHITE}Key Vaults in Resource Group:${BOLD_GREEN} $3 ${RESET}"
	az keyvault list --resource-group "$3" --query '[].{Name:name, Location:location}' -o table
        ;;
      secrets)
        if [ -z "$3" ]; then
          log_error "Please specify the vault name."
        fi
        echo -e "${BOLD_WHITE}Secrets in Key Vault:${BOLD_GREEN} $3 ${RESET}"
	secrets=$(az keyvault secret list --vault-name "$3" --query '[].{Name:name, Created:attributes.created}' -o table)
	if [ -z "$secrets" ]; then
	  echo "No secrets found in Vault: $3"
	  exit 0
	else
	  echo "$secrets" | nl -w 2 -s '. '
	  exit 0
	fi
        ;;
      *)
        log_error "Invalid option for 'list'"
        ;;
    esac
    ;;
  set)
    if [ -z "$2" ]; then
      echo -e "${BOLD_RED}Please add the Subscription ID to change ${RESET}"
      show_help
      exit 1
    fi
    az account set --subscription $2
    echo -e "${BOLD_MAGENTA}Validating the change to subscription ${RESET} "
    show=$(az account show --query '{SubscriptionId:id}' -o tsv)
    if [[ "$show" == "$2" ]]; then
	   echo -e "${BOLD_WHITE}[+] Changed to: ${BOLD_BLUE}$2 ${RESET}"
	   exit 0
    else
	   log_error "Someting wrong. Please check your account permissions"
    fi
    ;;
  akv)
    if [ -z "$2" ]; then
      log_error "Please add the resource group name."
    fi
      az keyvault list --resource-group "$2" --query '[].name' -o tsv
    ;;

  tag)
    if [ -z "$2" ]; then
      log_error "Missing ResourceGroup name and Key Vault name"
      show_help
      exit 1
    elif [ -z "$3" ]; then
      log_error "Missing Key Vault name"
    fi
    tag_secrets "$2" "$3"
    ;;
   onboard)
    if [ -z "$2" ]; then
      log_error "Missing ResourceGroup name and Key Vault name"
    elif [ -z "$3" ]; then
      log_error "Missing Key Vault name"
    fi
    update_vault "$2" "$3"
    ;;
  *)
    log_error "Invalid command."
    ;;
esac
        

