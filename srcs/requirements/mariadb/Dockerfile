FROM debian:bullseye

# Install MariaDB
RUN apt-get update -y && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Configure MariaDB to listen on all interfaces
RUN sed -i "s/bind-address            = 127.0.0.1/bind-address            = 0.0.0.1/" /etc/mysql/mariadb.conf.d/50-server.cnf || \
    sed -i "s/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# Create the socket directory
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Copy the initialization script
COPY tools/mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.sh

# Use the initialization script as the entrypoint
ENTRYPOINT ["/usr/local/bin/mariadb.sh"]
