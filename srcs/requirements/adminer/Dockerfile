FROM debian:bookworm

# Install PHP and wget to download Adminer
RUN apt-get update -y && \
    apt-get install -y php8.2 php8.2-mysqli wget && \
    rm -rf /var/lib/apt/lists/*

# Create the web directory
RUN mkdir -p /var/www/html

# Download a stable version of Adminer and save it as index.php
RUN wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" -O /var/www/html/index.php

# Set the working directory
WORKDIR /var/www/html

# Start PHP's built-in web server listening on port 8080
CMD ["php", "-S", "0.0.0.0:8080"]
