#!/bin/bash

# Set your CyberArk Privileged Cloud subdomain
SUBDOMAIN="latamlab"

# Set your OAuth confidential client credentials
CLIENT_ID="azureonboarding@cyberark.cloud.1741"
CLIENT_SECRET="CyberArk11@@"

# Authenticate and get an access token
ACCESS_TOKEN=$(curl -v -s -X POST \
    "https://${SUBDOMAIN}.cyberark.cloud/oauth2/platformtoken" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type"="client_credentials"              \
    --data-urlencode "client_id"="$CLIENT_ID"		\
    --data-urlencode "client_secret"="$CLIENT_SECRET"	)
    #-d "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&grant_type=client_credentials" | jq -r '.access_token')


echo $ACCESS_TOKEN
exit 0
# Safe details
SAFE_URL_ID="oxxo"
MEMBER_NAME="JohnDoe"  # Replace with the desired member name
MEMBER_TYPE="Group"   # Use "User" if it's a user

# Create an account on the safe
curl -X POST \
    "https://${SUBDOMAIN}.privilegecloud.cyberark.com/PasswordVault/API/Safes/${SAFE_URL_ID}/Members/" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{
        "memberName": "'${MEMBER_NAME}'",
        "searchIn": "Vault",
        "permissions": {
            "useAccounts": true,
            "retrieveAccounts": true,
            "listAccounts": true,
            "addAccounts": true
        },
        "MemberType": "'${MEMBER_TYPE}'"
    }'
