#!/bin/bash

# Variables
DOMAIN="r00tz0.xyz"
ADMIN_USER="Administrator"
PASS_FILE="/root/domain_pass.enc"
ENCRYPTION_KEY="SuperMasterKey"  # Use the same key used during encryption

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
   echo "This script must be run as root."
   exit 1
fi

# Install necessary packages
apt update && apt install -y realmd sssd adcli samba-common krb5-user packagekit openssl

# Check if the domain is accessible
echo "Checking domain accessibility..."
realm discover $DOMAIN >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: The domain $DOMAIN is not accessible. Check the network and DNS configurations."
    exit 1
fi

# Check if the machine is already joined to the domain
domain_check=$(realm list | grep -i "$DOMAIN")
if [ -n "$domain_check" ]; then
    echo "The machine is already joined to the domain $DOMAIN."
else
    echo "Joining the machine to the domain $DOMAIN..."

    # Check if the password file exists
    if [ ! -f "$PASS_FILE" ]; then
        echo "Error: Encrypted password file not found at $PASS_FILE."
        exit 1
    fi

    # Try to decrypt the password
    DOMAIN_PASS=$(openssl enc -aes-256-cbc -pbkdf2 -d -salt -in "$PASS_FILE" -pass pass:"$ENCRYPTION_KEY" 2>/tmp/decrypt_error.log)

    # Check if there was an error during decryption
    if [ $? -ne 0 ]; then
        echo "Error: Failed to decrypt the password. Make sure the encryption key and file are correct."
        echo "Error details: $(cat /tmp/decrypt_error.log)"
        exit 1
    fi

    # Try to join the machine to the domain
    echo "$DOMAIN_PASS" | realm join --user=$ADMIN_USER $DOMAIN

    # Verify if the machine successfully joined the domain
    domain_check=$(realm list | grep -i "$DOMAIN")
    if [ -n "$domain_check" ]; then
        echo "The machine successfully joined the domain."
    else
        echo "Error: Failed to join the domain. Check credentials and permissions."
        exit 1
    fi
fi

# Configure SSSD for authentication
echo "Configuring SSSD..."
systemctl restart sssd

# Allow login for all domain users
echo "Setting login permissions..."
realm permit --all

# Check if the domain user exists
getent passwd "$ADMIN_USER@$DOMAIN" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Warning: User $ADMIN_USER@$DOMAIN was not found. Authentication may not work properly."
fi

# Display domain configuration
realm list

echo "The machine is successfully configured on the domain $DOMAIN."
