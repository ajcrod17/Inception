FROM debian:Bookworm

# Install dependencies:
    # php7.4-fpm: Installs the PHP process manager engine,
    # php7.4-mysqli: PHP database driver extension. Without it, PHP engine wouldn't
    # know how to send SQL queries to MariaDB,
    # wget (for downloading wp-cli),
    # mariadb-client (to ping the database)
RUN apt-get update -y && \
    apt-get install -y php7.4-fpm php7.4-mysqli wget mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Download WP-CLI and make it globally accessible
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on TCP port 9000 instead of a local Unix socket
# This allows NGINX to forward requests to this container over the Docker network
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf

# Create the PID directory for PHP-FPM so it can start successfully
RUN mkdir -p /run/php

# Copy the initialization script
COPY tools/wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress.sh

# Set the working directory to where WordPress files will be stored
WORKDIR /var/www/html

# Run the initialization script
ENTRYPOINT ["/usr/local/bin/wordpress.sh"]
