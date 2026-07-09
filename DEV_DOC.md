# Inception - Developer Documentation

This document outlines the architecture, prerequisites, and operational instructions for developers maintaining the Inception infrastructure.

## Prerequisites
- A Linux host machine (or Virtual Machine) running a modern Debian-based OS.
- `docker` engine installed and running.
- `docker-compose` (or `docker compose` plugin) installed.
- `make` utility installed.
- Host resolution for the target domain (`acaldeir.42.fr` mapped to `127.0.0.1` in `/etc/hosts`).

## Architecture Overview
The project is orchestrated via `docker-compose.yml` and consists of 3 distinct services running on a custom bridge network (`inception_net`):
1. **MariaDB (`mariadb`)**: The database layer. Built from Debian Bookworm, running MariaDB listening on port 3306 on the internal Docker network. Uses a custom initialization script with `--bootstrap` to safely inject SQL data in the foreground without relying on background processes.
2. **WordPress (`wordpress`)**: The application layer. Built from Debian Bookworm. Runs PHP 8.2 FastCGI Process Manager (PHP-FPM) in the foreground listening on port 9000. Uses `wp-cli` to automatically install the core, configure the database connection, and create the administrator.
3. **NGINX (`nginx`)**: The web server and proxy layer. Built from Debian Bookworm. Configured to listen strictly on port 443 with TLSv1.2 and TLSv1.3 protocols. Proxies all PHP requests to the `wordpress` service.

## Operations and Makefile Usage
A `Makefile` is provided at the root of the repository to automate deployment:
- `make all` / `make`: Automatically creates the persistent volume directories on the host (`~/data/mariadb` and `~/data/wordpress`) and runs `docker compose up --build -d`.
- `make clean`: Brings down the infrastructure using `docker compose down`. The data volumes remain untouched.
- `make fclean`: A strict teardown command. It stops the containers, removes the named volumes, permanently deletes the host directories in `~/data/`, and prunes the Docker engine images.
- `make re`: Runs `fclean` followed by `all` to completely rebuild the project from scratch.

## Persistence Notes
Data persistence is achieved via Docker local volumes mapped directly to host directories. 
- `/var/lib/mysql` inside the MariaDB container maps to `${HOME}/data/mariadb`.
- `/var/www/html` is shared between the NGINX and WordPress containers, and maps to `${HOME}/data/wordpress`.
These host directories MUST exist prior to launching `docker-compose up`, otherwise Docker will create them with strict `root` ownership, which can lead to permission denied errors. The `Makefile` guarantees they are created safely.
