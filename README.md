# CyberArk Secrets Onboarding Script

## Overview
This script is used exclusively to transfer accounts from Azure Key Vault to CyberArk PAM or CyberArk Privileged Cloud. The onboarding process is automated for accounts and secrets; however, the creation of targets in SecretsHub must be performed manually.

## Prerequisites

Before using this script, ensure:

1. **This script automates the process of onboarding secrets from Azure Key Vault to CyberArk PAM or CyberArk Privileged Cloud.**
2. **The SecretsHub platform must already be installed in CyberArk PAM or CyberArk Privileged Cloud as a prerequisite.**
3. **Azure CLI** is installed and authenticated. Follow the [Azure CLI Installation Guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt).
4. **CyberArk CLI (`cybr`)** is installed. Refer to the [cybr-cli GitHub Repository](https://github.com/infamousjoeg/cybr-cli) for installation instructions.
5. You have the necessary permissions to access Azure and CyberArk resources.

## Usage
### General Syntax
```bash
./cyberark-secrets-onboarding.sh <command> [options]
```

### Commands
#### 1. **List Resources**
Perform listing operations for subscriptions, resource groups, key vaults, or secrets.

- **Subscriptions**: List all subscriptions accessible to your account.
  ```bash
  ./cyberark-secrets-onboarding.sh list subscriptions
  ```

- **Resource Groups**: List all resource groups in the current subscription.
  ```bash
  ./cyberark-secrets-onboarding.sh list resource
  ```

- **Key Vaults**: List all key vaults within a specified resource group.
  ```bash
  ./cyberark-secrets-onboarding.sh list akv <resource-group>
  ```

- **Secrets**: List all secrets stored in a specified key vault.
  ```bash
  ./cyberark-secrets-onboarding.sh list secrets <vault-name>
  ```

#### 2. **Set Subscription**
Change the active subscription.
```bash
./cyberark-secrets-onboarding.sh set <subscription-id>
```

#### 3. **Tag Secrets**
Apply CyberArk-compatible tags to all secrets in a specified key vault.
```bash
./cyberark-secrets-onboarding.sh tag <resource-group> <vault-name>
```

#### 4. **Onboard Secrets**
Onboard secrets from a key vault into CyberArk Privileged Cloud.
```bash
./cyberark-secrets-onboarding.sh onboard <resource-group> <vault-name>
```


## Example Workflows
### Setting the CPM Server
Edit the script to define the `CPM` variable:
```bash
CPM="<your-cpm-server-name>"
```

### Tagging Secrets in a Key Vault
To tag all secrets in a key vault:
```bash
./cyberark-secrets-onboarding.sh tag my-resource-group my-key-vault
```

### Onboarding Secrets to CyberArk Privileged Cloud
To onboard secrets:
```bash
./cyberark-secrets-onboarding.sh onboard my-resource-group my-key-vault
```

### Checking Prerequisites
The script automatically checks for required software and exits with instructions if any are missing.

## License
This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.

## Contact
For issues, suggestions, or contributions, contact:
**Aslan Ramos**  
<aslan.ramos@cyberark.com>


