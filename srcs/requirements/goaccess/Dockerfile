FROM debian:bookworm

# Install GoAccess
RUN apt-get update -y && \
    apt-get install -y goaccess && \
    rm -rf /var/lib/apt/lists/*

# GoAccess will crash if the access.log file does not exist when it starts.
# Because the containers boot simultaneously, we use a simple loop to wait until NGINX creates the log file.
# We then start GoAccess in real-time HTML mode, outputting directly to the shared WordPress volume!
CMD ["sh", "-c", "while [ ! -f /var/log/nginx/access.log ]; do sleep 1; done && goaccess /var/log/nginx/access.log -o /var/www/html/report.html --log-format=COMBINED --real-time-html --port=7890"]
