#!/bin/bash

# Create a dedicated directory for our SSL certificates
mkdir -p /etc/nginx/ssl

# Generate a self-signed TLS certificate using OpenSSL if it doesn't already exist
if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    echo "Generating self-signed SSL certificate for ${DOMAIN_NAME}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=PT/ST=Lisbon/L=Lisbon/O=42School/OU=acaldeir/CN=${DOMAIN_NAME}"
fi

# Dynamically replace the placeholder in our config with the actual domain name
echo "Configuring NGINX for domain: ${DOMAIN_NAME}"
sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/conf.d/default.conf

echo "Starting NGINX..."
# Start NGINX in the foreground so the Docker container doesn't exit
exec nginx -g "daemon off;"
