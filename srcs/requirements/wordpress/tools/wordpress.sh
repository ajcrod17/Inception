#!/bin/bash

# Wait for the MariaDB container to be fully booted and ready to accept connections
echo "Waiting for MariaDB..."
while ! mysqladmin ping -h"mariadb" -u"${MYSQL_USER}" -p"$(sed '1s/^\xEF\xBB\xBF//' /run/secrets/db_password | tr -d '\r\n')" --silent; do
    sleep 2
done
echo "MariaDB is up and running!"

# Check if WordPress is already downloaded/installed
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress core..."
    # Uses WP-CLI to pull the latest core WordPress files directly
    # into the current directory (/var/www/html).
    wp core download --allow-root

    echo "Configuring WordPress to connect to MariaDB..."
    # Generates a brand new wp-config.php file, plugging in environment
    # variables and securely reading database password from secrets.
    # Docker containers run as the root user by default, WP-CLI won't run out of
    # safety concerns unless the --allow-root flag is explicitly appended.
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="$(sed '1s/^\xEF\xBB\xBF//' /run/secrets/db_password | tr -d '\r\n')" \
        --dbhost="mariadb" \
        --allow-root

    echo "Installing WordPress and creating the administrator..."
    # Parse the admin credentials from the credentials secret
    ADMIN_USER=$(grep 'wp_chief' /run/secrets/credentials | cut -d ':' -f 1)
    ADMIN_PASS=$(grep 'wp_chief' /run/secrets/credentials | cut -d ':' -f 2 | tr -d '\n')

    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${ADMIN_PASS}" \
        --admin_email="admin@${DOMAIN_NAME}" \
        --allow-root

    echo "Creating a second standard user..."
    USER_NAME=$(grep 'wp_editor' /run/secrets/credentials | cut -d ':' -f 1)
    USER_PASS=$(grep 'wp_editor' /run/secrets/credentials | cut -d ':' -f 2 | tr -d '\n')
    
    wp user create "${USER_NAME}" "editor@${DOMAIN_NAME}" \
        --role=editor \
        --user_pass="${USER_PASS}" \
        --allow-root
        
    echo "Configuring Redis object cache..."
    # Inject Redis connection details into wp-config.php
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --allow-root
    wp config set WP_CACHE true --raw --allow-root
    
    # Install, activate, and enable the Redis object cache plugin
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root
        
    # Ensure proper permissions for the NGINX web server to read the files
    # Files downloaded via WP-CLI are owned by root. However, NGINX runs under
    # a limited system user profile called www-data. Recursively changes the
    # ownership of all WordPress files over to Nginx.
    chown -R www-data:www-data /var/www/html
fi

echo "Starting PHP-FPM in the foreground..."
# exec kills the shell script process and replaces PID1 in the container with the PHP engine.
# Launches the PHP FastCGI manager in the foreground (-F). This keeps the daemon
# running actively, listening on port 9000 for Nginx requests, and preventing
# the Docker container from exiting.
exec php-fpm8.2 -F
