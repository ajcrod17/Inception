#!/bin/bash

# Initialize the database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    echo "Starting MariaDB in background to create users..."
    # Starts MariaDB server, the ampersand (&) sends it to the background
    mysqld --user=mysql &
    # Store the process ID of the background server to be able to kill it later
    pid="$!"

    # Wait for the database to start
    sleep 5

    echo "Creating users and database..."
    
    # Read secrets and strip any trailing newlines from echo
    DB_PASS=$(cat /run/secrets/db_password | tr -d '\n')
    DB_ROOT_PASS=$(cat /run/secrets/db_root_password | tr -d '\n')
    
    # Execute SQL commands to set up the database and users
    # -e "...": Tells the mysql client CLI to execute the string inside the quotes as a direct SQL query
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    # The % wildcard allows MYSQL_USER to log in from any host — WordPress container will be allowed
    # to connect over the Docker network
    mysql -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"
    # Tells MariaDB to reload its internal grant tables so all these new changes take effect
    mysql -u root -p"${DB_ROOT_PASS}" -e "FLUSH PRIVILEGES;"

    echo "Shutting down background MariaDB..."
    mysqladmin -u root -p"${DB_ROOT_PASS}" shutdown
    # wait until the background process completely finishes shutting down
    wait "$pid"
fi

echo "Starting MariaDB..."
# Start MariaDB in the foreground
# exec: Replaces the entire Bash script process with the target command. The script process completely dies,
# and mysqld_safe takes over PID 1 inside the container. Automatically restarts the database server if it crashes
exec mysqld_safe --user=mysql
