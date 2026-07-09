*This project has been created as part of the 42 curriculum by acaldeir.*

## Description
Inception is a system administration project that focuses on Docker and containerization. The goal is to build a complete, resilient infrastructure using multiple custom Docker containers orchestrated by Docker Compose. The architecture consists of a MariaDB database, a WordPress PHP-FPM application, and an NGINX web server securely exposing the site via HTTPS (TLSv1.2/1.3). No pre-built images are used; everything is built from raw Debian Bookworm base images.

## Instructions
To build and run the infrastructure:
1. Ensure you have Docker and Docker Compose installed.
2. The `Makefile` at the root of the repository automates the entire process.
3. Run `make all` to build the images, create the network, and start the containers.
4. Navigate to `https://<your_login>.42.fr` in your browser. (Note: you must update your `/etc/hosts` file to point this domain to `127.0.0.1`).
5. Run `make clean` to stop the containers, and `make fclean` to completely purge the volumes and data.

## Resources
- **Docker Official Documentation**: Used for understanding Dockerfiles, volumes, and networking.
- **NGINX & OpenSSL Documentation**: Used to properly configure the server blocks and generate self-signed certificates.
- **MariaDB & WordPress Documentation**: Used for writing the initialization shell scripts (`--bootstrap` for MariaDB and `wp-cli` for WordPress).
- **AI Usage**: An AI coding assistant was used heavily throughout this project to help design the architecture, draft the initial Dockerfiles, write the bash initialization scripts securely, and construct this documentation.
