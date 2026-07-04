# Inception Project Implementation Plan

This plan outlines the directory skeleton that will be generated for your 42 Inception project, as well as a step-by-step implementation guide with estimated completion times.

## Proposed Skeleton Structure

Based on the subject requirements (Version 5.3), I will create the following files and directories inside your `/home/acaldeir/Projects/M5/Inception/` folder:

```text
/Inception
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── conf/
        │   ├── tools/
        │   ├── Dockerfile
        │   └── .dockerignore
        ├── nginx/
        │   ├── conf/
        │   ├── tools/
        │   ├── Dockerfile
        │   └── .dockerignore
        └── wordpress/
            ├── conf/
            ├── tools/
            ├── Dockerfile
            └── .dockerignore
```

*Note: The bonus folder can be added later if you decide to tackle the bonus part.*

## Step-by-Step Implementation Guide & Time Estimates

Here is a roadmap for implementing the project, with rough time estimations based on typical 42 curriculum progress.

### Phase 1: Setup and Environment (Estimated: 2-3 hours)
1. **VM Preparation:** Ensure your VM is set up correctly and Docker / Docker Compose are installed.
2. **Hosts File Configuration:** Configure `/etc/hosts` to point `acaldeir.42.fr` (replace with your exact login) to `127.0.0.1`.
3. **Environment Variables & Secrets:** Fill in `.env` with generic configurations (like `DOMAIN_NAME`) and securely place passwords in the `secrets/` directory. **Do not commit secrets to Git!**

### Phase 2: MariaDB Service (Estimated: 4-6 hours)
1. **Dockerfile:** Write a Dockerfile (Debian base) to install `mariadb-server` and `mariadb-client`.
2. **Database Initialization Script:** Create a bash script (in `tools/`) to run at startup. It should:
   - Initialize the database directory if it's empty.
   - Start the MariaDB daemon temporarily.
   - Create the WordPress database, a root user, and a regular user based on your secrets/environment variables.
   - Stop the temporary daemon and restart it in the foreground (`mysqld_safe`).
3. **Test:** Run the container and verify you can connect locally inside it using the configured user/password.

### Phase 3: WordPress + PHP-FPM Service (Estimated: 5-8 hours)
1. **Dockerfile:** Write a Dockerfile (Debian base) to install `php-fpm`, `php-mysqli`, and `wget`.
2. **WP-CLI (WordPress CLI):** Download and install WP-CLI inside the container to manage the WordPress installation.
3. **Initialization Script:** Create a script (in `tools/`) that:
   - Waits for MariaDB to be fully ready (using `mariadb-client` or a wait loop).
   - Downloads WordPress core.
   - Creates `wp-config.php` dynamically using the database credentials.
   - Installs WordPress (creates the admin user and a secondary user using WP-CLI).
   - Starts `php-fpm` in the foreground.
4. **PHP-FPM Conf:** Adjust the `www.conf` pool to listen on port 9000 instead of a Unix socket.

### Phase 4: NGINX Service (Estimated: 4-6 hours)
1. **Dockerfile:** Write a Dockerfile (Debian base) to install `nginx` and `openssl`.
2. **TLS Configuration:** Generate a self-signed TLSv1.2/TLSv1.3 certificate using `openssl` in your setup script or Dockerfile.
3. **NGINX Conf:** Configure the server block to listen *only* on port 443 with SSL, and proxy PHP requests to the WordPress container on port 9000.
4. **Test:** Run the container standalone to ensure it builds correctly and answers on HTTPS.

### Phase 5: Docker Compose & Network (Estimated: 3-5 hours)
1. **docker-compose.yml:** Tie the three services together.
   - Define a custom bridge network.
   - Mount named volumes for the database (`${HOME}/data/mariadb` or `/home/acaldeir/data/mariadb`) and WordPress files (`${HOME}/data/wordpress` or `/home/acaldeir/data/wordpress`).
   - Map port 443 on the host to port 443 on the NGINX container.
   - Pass the `.env` file and secrets to the containers.
   - Define restart policies (`restart: always` or `on-failure`).

### Phase 6: Makefile and Documentation (Estimated: 2-4 hours)
1. **Makefile:** Write targets for `all` (build and up), `clean` (down and remove containers/networks), `fclean` (remove volumes and images), and `re`. Ensure the Makefile creates the host data directories (`${HOME}/data/...`) before running `docker-compose up`.
2. **Documentation:** Write the `README.md`, `USER_DOC.md`, and `DEV_DOC.md` fulfilling all constraints specified in the subject.

---

**Total Estimated Time:** 20 - 32 hours.

## User Review Required
Please review the proposed directory structure and the implementation plan above. 

**Are you ready for me to execute the creation of this skeleton framework?** If you approve, click "Proceed" or reply confirming, and I will generate the folders and empty files.
