#!/bin/bash

# Set your CyberArk Privileged Cloud subdomain
SUBDOMAIN="your-subdomain"

# Set your OAuth confidential client credentials
CLIENT_ID="your-client-id"
CLIENT_SECRET="your-client-secret"

# Authenticate and get an access token
ACCESS_TOKEN=$(curl -s -X POST \
    "https://${SUBDOMAIN}.privilegecloud.cyberark.com/PasswordVault/Logon" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=${CLIENT_ID}&password=${CLIENT_SECRET}" | jq -r '.access_token')

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
