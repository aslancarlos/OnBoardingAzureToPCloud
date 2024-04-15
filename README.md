
# Onboarding accounts from Azure Key Vault to CyberArk PAM to be used by CyberArk Secrets HUB

Script com objetivo de importar secrets da Azure Key Vault para o CyberArk PAM.
Realizado as automaticações e lógicas dentro deste script para termanecer mais simples possível de entendimento para todos.


## Support

For support, email aslan.ramos@cyberark.com.


## Requirements
The  "Swiss Army Knife" command-line interface (CLI) for easy human and non-human interaction with CyberArk's suite of products.
[cybr-cli](https://github.com/infamousjoeg/cybr-cli)


Azure Client
[Azure cli](https://github.com/Azure/azure-cli)


## License
[MIT](https://choosealicense.com/licenses/mit/)

## Authors

- [@aslancarlos](https://www.github.com/aslancarlos)



## Features
- Fetch all Subscription based on permission from user logged with Azure CLI on the terminal
- Fetch all Azure Key Vault (AKV) per Resource Group.
- By each AKV, get all information from the secrets
- Check if exist the safe with the AKV name, if not, creates. 
- Create an account with details from Secrets on the Safe with AKV name
 


## License

[MIT](https://choosealicense.com/licenses/mit/)


## Support

For support, email aslan.ramos@cyberark.com.


## Authors

- [@aslancarlos](https://www.github.com/aslancarlos)


## Features

- Extract all secrets from a AKV/RG/Sub
- Add the required tags from CyberArk Secretshub
- Add support to recursive on ResourceGroups




## Documentation

Do you need the Conjur Cloud CLI.
- [Conjur Cloud CLI](https://cyberark.my.site.com/mplace/s/#software)

Do you need a CyberArk Tenant with Conjur Cloud and an user with permissions to access and manage Conjur Cloud policies.