FROM debian:Bookworm

# Install NGINX web server and OpenSSL for certificate generation
RUN apt-get update -y && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Copy our custom server configuration into NGINX's config directory
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Copy the initialization script
COPY tools/nginx.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx.sh

# Run the initialization script
ENTRYPOINT ["/usr/local/bin/nginx.sh"]
