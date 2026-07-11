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

## Bonuses Included
This project includes 5 additional services demonstrating advanced container orchestration:
1. **Adminer**: A lightweight database management GUI.
2. **Static Site**: A custom HTML/CSS showcase served via a Node.js Express server.
3. **Redis**: An object caching server seamlessly integrated with WordPress.
4. **GoAccess**: A real-time web log analyzer that parses NGINX access logs into a visual dashboard.
5. **FTP Server**: A vsftpd container mapping directly to the WordPress volume for external file management.

## Project Description: Architecture & Technical Comparisons
This project relies on several key technical decisions involving containerization, security, networking, and data persistence:

### Virtual Machines vs Docker
- **Virtual Machines** emulate entire physical hardware systems, running a full guest Operating System (OS) with its own kernel. This makes them highly isolated but very resource-heavy and slow to boot.
- **Docker** leverages containerization, allowing applications to run in isolated user spaces while sharing the host machine's kernel. Containers are lightweight, start instantly, and only package the application code and its dependencies, rather than an entire OS.

### Secrets vs Environment Variables
- **Environment Variables** are easily accessible by any process running within the container and can often be leaked inadvertently (e.g., through crash logs, `phpinfo()`, or the `env` command). 
- **Docker Secrets** provide a far more secure mechanism. They are injected as read-only files strictly mounted into memory (`/run/secrets/`), meaning they are never written to disk or exposed to standard environment dumps, vastly improving the security of passwords like the MariaDB root password.

### Docker Network vs Host Network
- **Host Network** removes isolation entirely, attaching the container directly to the host machine's network interfaces. If an application uses port 80, it binds directly to the host's port 80.
- **Docker Network (Bridge)** creates a private, isolated virtual LAN for the containers. In this project, `inception_net` ensures that the database and WordPress containers cannot be accessed directly from the host. They can only communicate with each other securely, while NGINX alone maps port `443` to the outside world.

### Docker Volumes vs Bind Mounts
- **Bind Mounts** directly link a specific folder on the host machine to a directory inside the container. This tightly couples the container to the host filesystem, often leading to permission issues.
- **Docker Volumes** are managed entirely by the Docker daemon (usually stored in `/var/lib/docker/volumes/`). They are OS-independent, much safer, and are the recommended way to persist database and website files across container restarts without cluttering the host's primary filesystem.

## Resources
- **Docker Official Documentation**: Used for understanding Dockerfiles, volumes, and networking.
- **NGINX & OpenSSL Documentation**: Used to properly configure the server blocks and generate self-signed certificates.
- **MariaDB & WordPress Documentation**: Used for writing the initialization shell scripts (`--bootstrap` for MariaDB and `wp-cli` for WordPress).
- **AI Usage**: An AI coding assistant was used heavily throughout this project to help design the architecture, draft the initial Dockerfiles, write the bash initialization scripts securely, and construct this documentation.
