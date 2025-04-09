#!/bin/bash

# Set variables
DOMAIN="ubuntulandscape.r00tz0.xyz"
CF_API_TOKEN="your_cloudflare_api_token"  # Set your Cloudflare API token here
ACME_SH_DIR="$HOME/.acme.sh"
LOG_FILE="/var/tmp/certificate_issuance.log"

# Ensure acme.sh is installed
if [ ! -d "$ACME_SH_DIR" ]; then
    echo "acme.sh is not installed. Installing..."
    curl https://get.acme.sh | sh
else
    echo "acme.sh is already installed."
fi

# Set Cloudflare API token as an environment variable
export CF_API_TOKEN="$CF_API_TOKEN"

# Issue the certificate using Cloudflare DNS challenge
echo "Issuing certificate for $DOMAIN using Cloudflare DNS challenge..."
"$ACME_SH_DIR/acme.sh" --issue --dns dns_cf -d "$DOMAIN"

# Check if the certificate was issued successfully
if [ $? -eq 0 ]; then
    echo "Certificate issued successfully for $DOMAIN."

    # Log the certificate issuance result
    echo "$(date): Certificate issued successfully for $DOMAIN" >> "$LOG_FILE"

    # Export cert for Keeper Automator (if needed)
    echo "Exporting certificate for Keeper Automator..."
    CERT_DIR="$ACME_SH_DIR/$DOMAIN"
    openssl pkcs12 -export -passout pass: \
        -out "$CERT_DIR/$DOMAIN.pfx" \
        -inkey "$CERT_DIR/$DOMAIN.key" \
        -in "$CERT_DIR/fullchain.cer" \
        -certfile "$CERT_DIR/$DOMAIN.cer"

    if [ $? -eq 0 ]; then
        echo "PKCS12 certificate created successfully for Keeper Automator."
        echo "$(date): PKCS12 certificate created for $DOMAIN." >> "$LOG_FILE"
    else
        echo "Error: Failed to create PKCS12 certificate."
        echo "$(date): Failed to create PKCS12 certificate for $DOMAIN." >> "$LOG_FILE"
        exit 1
    fi
else
    echo "Error: Failed to issue certificate for $DOMAIN using Cloudflare DNS challenge."
    echo "$(date): Failed to issue certificate for $DOMAIN." >> "$LOG_FILE"
    exit 1
fi
