#!/bin/bash

# Initialize the database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql


    echo "Setting up WordPress database and users via bootstrap..."
    
    # Read secrets and strip any trailing newlines from echo
    DB_PASS=$(cat /run/secrets/db_password | tr -d '\n')
    DB_ROOT_PASS=$(cat /run/secrets/db_root_password | tr -d '\n')

    # Create a temporary file with all the SQL initialization commands
    cat << EOF > /tmp/init.sql
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Boot MariaDB safely in the foreground, inject the SQL file, and immediately shut down
    mysqld --user=mysql --bootstrap < /tmp/init.sql
    
    # Remove the temporary file holding the passwords for security
    rm -f /tmp/init.sql
fi

echo "Starting MariaDB..."
# Start MariaDB in the foreground
# exec: Replaces the entire Bash script process with the target command. The script process completely dies,
# and mysqld_safe takes over PID 1 inside the container. Automatically restarts the database server if it crashes
exec mysqld_safe --user=mysql
