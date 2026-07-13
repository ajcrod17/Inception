#!/bin/bash

# Parse credentials from the secret file
FTP_USER=$(cut -d ':' -f 1 /run/secrets/ftp_credentials)
FTP_PASS=$(cut -d ':' -f 2 /run/secrets/ftp_credentials | tr -d '\n')

# Check if user already exists (">/dev/null" prevents user info from being displayed on the screen.)
if ! id "$FTP_USER" &>/dev/null; then
    echo "Creating FTP user: $FTP_USER"
    # Create the user but securely map them to the same UID (33) and GID (33) as www-data!
    # This completely eliminates file permission conflicts between NGINX and the FTP server.
    useradd -u 33 -o -g 33 -d /var/www/html -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    echo "User created successfully."
fi

# Ensure the empty directory for vsftpd jailing exists
mkdir -p /var/run/vsftpd/empty

echo "Starting vsftpd..."
# Run vsftpd in the foreground
exec /usr/sbin/vsftpd /etc/vsftpd.conf
