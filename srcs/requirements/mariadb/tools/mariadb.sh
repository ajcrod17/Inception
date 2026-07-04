#!/bin/bash

# Initialize the database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    echo "Starting MariaDB in background to create users..."
    mysqld --user=mysql &
    pid="$!"

    # Wait for the database to start
    sleep 5

    echo "Creating users and database..."
    # Execute SQL commands to set up the database and users
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)'; "
    mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';"
    mysql -u root -p"$(cat /run/secrets/db_root_password)" -e "FLUSH PRIVILEGES;"

    echo "Shutting down background MariaDB..."
    mysqladmin -u root -p"$(cat /run/secrets/db_root_password)" shutdown
    wait "$pid"
fi

echo "Starting MariaDB..."
# Start MariaDB in the foreground
exec mysqld_safe --user=mysql
