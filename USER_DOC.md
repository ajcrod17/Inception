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
