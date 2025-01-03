### User Guide for CyberArk Onboarding Script

This guide explains how to use the CyberArk onboarding script to manage Azure resources and integrate them with CyberArk Privileged Cloud (PCLOUD). It includes instructions for setup, commands, and an example workflow.

---

### Prerequisites

Before using this script, ensure the following:

1. **Azure CLI**: Installed and configured. Follow the guide at https://learn.microsoft.com/en-us/cli/azure/install-azure-cli.
2. **ARK CLI**: Installed and configured. Follow the guide at https://github.com/cyberark/ark-sdk-python/tree/main.
3. **CPM Configuration**: Edit the script to define the `CPM` variable with the name of the CPM Server used in CyberArk PAM Safe.
4. **SecretsHub Platform Imported**: Ensure the SecretsHub Platform has been imported into PCLOUD. For optimal display of account data after the platform is imported:
   - Edit the platform.
   - Navigate to: `Target Account Platform -> UI & Workflows -> Properties -> Required`.
   - Add `Username`.

   This setup ensures that when accounts are imported, the username field will display the name of the secret imported from the Azure Key Vault (AKV).

---

### Setting Up the Script

1. Download the script and make it executable:
   ```bash
   chmod +x cyberark-secrets-onboarding.sh
   ```
2. Open the script in a text editor and locate the following line:
   ```bash
   CPM=""
   ```
   Replace the empty string with the name of your CPM Server, e.g., `CPM="MyCPMServer"`.

3. Verify that the required tools are installed by running:
   ```bash
   ./cyberark-secrets-onboarding.sh list subscriptions
   ```
   If any tool is missing, follow the installation guides in the prerequisites section.

---

### Script Usage

The script provides several commands to manage resources and onboard them to CyberArk.

#### General Syntax
```bash
./cyberark-secrets-onboarding.sh <command> [options]
```

#### Commands and Examples

1. **List Resources**
   - **List Subscriptions**: Shows all subscriptions accessible to your account.
     ```bash
     ./cyberark-secrets-onboarding.sh list subscriptions
     ```
   - **List Resource Groups**: Displays all resource groups in the current subscription.
     ```bash
     ./cyberark-secrets-onboarding.sh list resource
     ```
   - **List Key Vaults**: Lists all Key Vaults in a specified resource group.
     ```bash
     ./cyberark-secrets-onboarding.sh list akv <resource-group>
     ```
   - **List Secrets**: Lists all secrets stored in a specific Key Vault.
     ```bash
     ./cyberark-secrets-onboarding.sh list secrets <vault-name>
     ```

2. **Set Active Subscription**
   Change the active Azure subscription:
   ```bash
   ./cyberark-secrets-onboarding.sh set <subscription-id>
   ```

3. **Tag Secrets for CyberArk**
   Add metadata to all secrets in a specified Key Vault:
   ```bash
   ./cyberark-secrets-onboarding.sh tag <resource-group> <vault-name>
   ```

4. **Onboard Secrets to CyberArk**
   Create the safe and add secrets to CyberArk PCLOUD:
   ```bash
   ./cyberark-secrets-onboarding.sh onboard <resource-group> <vault-name>
   ```

---

### Example Workflow

To migrate Azure Key Vault secrets to CyberArk PCLOUD, follow these steps:

1. **Tag Secrets**
   Tag all secrets in the Key Vault:
   ```bash
   ./cyberark-secrets-onboarding.sh tag my-resource-group my-key-vault
   ```

2. **Onboard to CyberArk**
   Create a safe and onboard secrets to CyberArk PCLOUD:
   ```bash
   ./cyberark-secrets-onboarding.sh onboard my-resource-group my-key-vault
   ```

The script, during the onboarding process, will create a SAFE with the name of the corresponding AKV. Each account in CyberArk will represent a secret imported from the AKV. 

The SAFE will already include the necessary permissions for the "SecretsHub" user, enabling synchronization. Note that manual synchronization setup within the SecretsHub console is required as a final step.

---

### Troubleshooting

1. **Missing CPM Server Configuration**:
   If the script displays an error about a missing CPM Server:
   - Open the script file.
   - Locate the `CPM` variable and set its value.

2. **Missing Azure CLI**:
   If Azure CLI is not installed, follow the installation guide: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli.

3. **Missing ARK CLI**:
   If ARK CLI is not installed, follow the installation guide: https://github.com/cyberark/ark-sdk-python/tree/main.

4. **ARK CLI Session Expiry**:
   The ARK CLI session has a short expiration time. Ensure you are logged in before executing the script to avoid migration issues.

5. **Invalid Command**:
   Run the script without arguments to display the help menu:
   ```bash
   ./cyberark-secrets-onboarding.sh
   ```

6. **Using Azure App Registration for Migration**:
   Migration is supported using an Azure App Registration, provided it has the necessary permissions. Ensure the required permissions for CyberArk SecretsHub are added. Refer to the CyberArk SecretsHub documentation for detailed requirements.

---

### Help Menu

Run the script without arguments or use the `help` command to display the available options:
```bash
./cyberark-secrets-onboarding.sh
```

This will output the command list and examples for reference.

---

### Notes

- Always execute the commands in the migration workflow in order: **tag**, then **onboard**.
- Use the `list` commands to identify resources and prepare for further actions.
- Ensure your Azure account has the necessary permissions to access and manage resources.

For further assistance, consult your system administrator or CyberArk support team.

