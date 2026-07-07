FROM debian:Bookworm

# Install MariaDB inside the image
RUN apt-get update -y && \
    apt-get install -y mariadb-server mariadb-client && \
    # Clean up apt cache to reduce image size
    rm -rf /var/lib/apt/lists/*

# Configure MariaDB to listen on all interfaces instead of only localhost
# This is required for the WordPress container to connect to the database
RUN sed -i "s/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# Remove the default database to force our initialization script to run
RUN rm -rf /var/lib/mysql/*

# Create the socket directory. MariaDB uses a local Unix socket file to handle local communication
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Copy the initialization script to the image
COPY tools/mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.sh

# Use the initialization script as the entrypoint
ENTRYPOINT ["/usr/local/bin/mariadb.sh"]
