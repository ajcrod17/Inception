FROM debian:bookworm

# Install the official Redis server package
RUN apt-get update -y && \
    apt-get install -y redis-server && \
    rm -rf /var/lib/apt/lists/*

# Start Redis in the foreground. 
# --bind 0.0.0.0: Allows it to accept connections from other containers on the Docker network.
# --protected-mode no: Disables protected mode since we are safely isolated inside a private bridge network.
CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no"]
