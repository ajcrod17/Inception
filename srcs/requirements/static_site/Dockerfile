FROM debian:bookworm

# Install Node.js and npm
RUN apt-get update -y && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/static_site

# Copy the server script and the HTML file
COPY conf/server.js /var/www/static_site/
COPY conf/index.html /var/www/static_site/

WORKDIR /var/www/static_site

# Initialize a node project and install Express.js to serve the static files
RUN npm init -y && npm install express

# Start the Node.js server
CMD ["node", "server.js"]
