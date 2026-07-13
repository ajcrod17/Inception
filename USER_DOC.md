# Inception - User Documentation

This document provides instructions for end-users and administrators interacting with the live WordPress site.

## Accessing the Site
1. Open your web browser.
2. Navigate to `https://acaldeir.42.fr` (You will need to accept the self-signed SSL certificate warning).
3. You will see the public-facing WordPress site.

## Administrator Access
1. To log into the backend and manage the site, go to `https://acaldeir.42.fr/wp-admin`.
2. **Credentials**: The administrator credentials (`wp_chief` and their password) are stored securely in the `secrets/` directory on the host machine.
3. As the administrator, you can change the theme, install plugins, write posts, and approve comments from other users.

## Standard User Access
A secondary standard user is also created automatically. They can log in to the dashboard to write posts or comments, but their capabilities are limited (they cannot alter the site's core settings). Their credentials are also located in the `secrets/` folder.

## Comment Moderation
By default, if an unauthenticated user or a new standard user leaves a comment on a blog post, it will not appear immediately. It is placed into the **Pending Moderation** queue. The Administrator must log into the `wp-admin` dashboard and approve the comment before it becomes publicly visible.

## Bonus Features Access
In addition to the core WordPress functionality, the following tools are available:
- **Adminer (Database GUI):** Navigate to `http://127.0.0.1:8080`. Select "MySQL" as the system, "mariadb" as the server, and log in with the root or user credentials from the `secrets/` directory.
- **Static Showcase Site:** Navigate to `http://127.0.0.1:3000` to view the custom portfolio site.
- **GoAccess Analytics Dashboard:** Navigate to `https://acaldeir.42.fr/report.html` to see real-time traffic statistics for the WordPress site.
- **FTP Access:** Connect using any FTP client (like FileZilla) to host `127.0.0.1`. The username is `ftp_user` and the password is the one provided in `secrets/ftp_credentials.txt`.
- **Redis Cache:** Integrated automatically. You can verify the connection status by logging into WordPress as an administrator and checking **Settings > Redis**.

---

## Evaluation Demo Instructions

Use the following commands during your evaluation defense to step-by-step prove infrastructure compliance and validity to your evaluator.

### 1. Repository Hygiene & Preliminary Audits

| Command | Purpose / Description | Expected Safe Response |
| :--- | :--- | :--- |
| `ls -la` | Proves files are structured according to subject rules. | Shows `srcs/` and `Makefile` located directly at the root. |
| `find srcs -type f \| sort` | Confirms all components are custom blueprints. | Lists your custom configuration files and `.sh` scripts. |
| `grep -RIn "replace with pass\\|replace with pass" .` | Audits repository for plain-text password leakage. | **Must only** return matches inside the `secrets/` files. |

### 2. General Docker Infrastructure Security

| Command | Purpose / Description | Expected Safe Response |
| :--- | :--- | :--- |
| `grep -RIn "network:\\s*host\\|\\blinks:\\|--link" srcs Makefile` | Checks for forbidden shortcuts or legacy configurations. | **Blank output** (no forbidden parameters found). |
| `docker network ls \| grep inception_net` | Verifies the custom isolation network exists. | Shows `inception_net` operating with the `bridge` driver. |
| `grep -RIn "tail -f\\|sleep infinity\\|/dev/null\\|/dev/random" srcs` | Checks for artificial script keep-alive hacks. | Empty output, or *only* safe shell redirection (`&>/dev/null`). |
| `grep -RIn "^FROM " srcs/requirements/*/Dockerfile` | Proves use of the mandated base distribution. | Every service returns `FROM debian:bookworm`. |

### 3. Network Ports & Encryption Validation

| Command | Purpose / Description | Expected Safe Response |
| :--- | :--- | :--- |
| `docker compose -f srcs/docker-compose.yml ps` | Displays running containers and public port bindings. | Lists all services `Up`. Nginx displays **only** port 443. |
| `ss -tulpen \| grep -E ":443\\b\\|:80\\b"` | Verifies host socket exposures directly. | Returns active line listening on 443; port 80 is absent. |
| `curl -I http://acaldeir.42.fr` | Confirms unencrypted HTTP is inaccessible. | Returns connection failure (`Failed to connect / Connection refused`). |
| `curl -k -I https://acaldeir.42.fr` | Validates that WordPress responds over TLS/SSL. | Returns `HTTP/1.1 200 OK`. |
| `echo \| openssl s_client -connect acaldeir.42.fr:443 -tls1_2 \| head -n 20` | Proves Nginx handles TLS 1.2 handshakes properly. | Successful secure connection. Shows `CN=acaldeir.42.fr`. |
| `echo \| openssl s_client -connect acaldeir.42.fr:443 -tls1_3 \| head -n 20` | Proves Nginx handles TLS 1.3 handshakes properly. | Successful secure connection with TLSv1.3 session details. |

### 4. Volumes, WordPress Data, and User Configuration

| Command | Purpose / Description | Expected Safe Response |
| :--- | :--- | :--- |
| `docker volume inspect srcs_wordpress_vol` | Verifies data volume persistence mapping. | JSON output showing mount binding to `/home/acaldeir/data/wordpress`. |
| `docker volume inspect srcs_mariadb_vol` | Verifies database volume persistence mapping. | JSON output showing mount binding to `/home/acaldeir/data/mariadb`. |
| `docker exec wordpress wp core is-installed --allow-root` | Proves database configuration is built out. | Returns no error (WordPress engine confirms it is installed). |
| `docker exec wordpress wp user list --allow-root --fields=user_login,roles` | Validates registered WordPress users and identities. | Shows `wp_chief` as administrator and verifies no name contains "admin". |

### 5. Interactive Database Inspection Validation

To prove that the relational database is actively populated with your application data tables, execute this sequence exactly:

```bash
# 1. Open an interactive backdoor terminal into the database container
docker exec -it mariadb sh

# 2. Extract credentials from the secure vault (inside the container prompt)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password | tr -d '\n')

# 3. Access the MariaDB interactive client interface
mysql -u root -p"$DB_ROOT_PASS"

# 4. Run the structural SQL queries (remember the trailing semicolons!)
SHOW DATABASES;    # Verifies 'wordpress' database exists
USE wordpress;     # Selects the workspace environment
SHOW TABLES;       # Lists all 'wp_*' tables to prove active communication
```

### 6. Bonus Service Rapid Verification

### Adminer (Database GUI)
* **How to Test:** Connect to `http://127.0.0.1:8080` in your browser.
* **Login:** 
    * Server: `mariadb`
    * Database: `wordpress`
    * User: `wpuser`
    * Password: `[PASSWORD]` (stored in `secrets/db_password.txt`)
* **Purpose:** Tests Adminer database dashboard functionality.
* **Expected Response:** Loads the database graphical interface login dashboard successfully.

### Static Portfolio Site
* **How to Test:** Connect to `http://127.0.0.1:3000` in your browser.
* **Purpose:** Tests the Node.js static framework container.
* **Expected Response:** Loads your custom portfolio static web application.

### GoAccess Analytics
* **How to Test:** Connect to `https://acaldeir.42.fr/report.html` in your browser.
* **Purpose:** Tests the GoAccess real-time traffic dashboard parser.
* **Expected Response:** Renders operational traffic graph analysis profiles and charts smoothly.

### Redis Cache Object Store
* **How to Test:** Log into the WordPress admin panel (`https://acaldeir.42.fr/wp-admin`), navigate to **Settings > Redis**.
* **Purpose:** Verifies memory-caching database acceleration.
* **Expected Response:** Shows the status as "Connected" along with live cache metrics and hits.

### FTP Server (vsftpd)
* **How to Test (Read Directory):** Run `curl ftp://127.0.0.1/ --user ftp_user:ftp_pass` in your terminal.
* **Purpose:** Verifies passive FTP server file integration and read permissions.
* **Expected Response:** Displays a raw text directory listing of your remote WordPress volume directory.

* **How to Test (Write/Upload a File):** 1. Create a dummy file locally: `echo "Hello from FTP evaluation" > test_ftp.txt`
  2. Upload it via FTP: `curl -T test_ftp.txt ftp://127.0.0.1/ --user ftp_user:ftp_pass`
* **Purpose:** Verifies that the FTP daemon has correct write privileges and maps properly to user ID 33 (`www-data`) without causing permission blocks inside the volume.
* **Expected Response:** The upload finishes cleanly with a progress bar. You can instantly confirm it worked by running `docker exec wordpress ls -la /var/www/html` to see `test_ftp.txt` sitting safely inside your active WordPress files!