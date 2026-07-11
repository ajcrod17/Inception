FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y vsftpd && \
    rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/ftp.sh

CMD ["/usr/local/bin/ftp.sh"]
