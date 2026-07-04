# School PC / Cluster Setup Instructions

Because your `$HOME` directory at 42 has a strict storage quota, you **must not** run Docker or store heavy data directly in your home folder. However, the subject mandates that your source code and volumes follow specific rules.

Here is the correct workflow for setting up your environment on a school PC/VM while respecting the quota:

---

## 1. Where to store your Source Code

You should **keep your `Inception` repository (the Makefile, scripts, Dockerfiles, etc.) in your `$HOME` directory**. 
- Source code takes up very little space.
- The `/sgoinfre` directory is temporary and gets wiped when you log out or the machine reboots. If you put your repo there, you will lose your work!

---

## 2. Install Docker & Configure it for `sgoinfre`

The Docker daemon itself and all its heavy data (images, containers, build cache) **must run on `/sgoinfre`**. 

1. **Check for school scripts:** Most 42 campuses provide a script (e.g., `init_docker.sh`) to automatically install or configure Docker to use `/sgoinfre/$USER/docker`. If your campus has this, **run it**!
2. **Manual configuration (if no script exists):**
   If you must install Docker yourself, ensure its `data-root` is set to `/sgoinfre`.
   
   ```bash
   # Install Docker (Debian/Ubuntu example)
   sudo apt-get update
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

   # Stop the service
   sudo systemctl stop docker

   # Create the Docker data directory in sgoinfre
   mkdir -p /sgoinfre/$USER/docker

   # Configure Docker to use it (create/edit daemon.json)
   sudo sh -c 'echo "{\"data-root\": \"/sgoinfre/$USER/docker\"}" > /etc/docker/daemon.json'

   # Start the service again
   sudo systemctl start docker
   ```

---

## 3. Configure the `/etc/hosts` File

Your NGINX container will be configured to serve the WordPress site exclusively through your specific domain name (`acaldeir.42.fr`).

Run this command to point the domain to the local machine:
```bash
sudo sh -c 'echo "127.0.0.1   acaldeir.42.fr" >> /etc/hosts'
```

---

## 4. Create Host Data Directories (with Symlinks)

The subject strictly requires your persistent data to be stored in `/home/$USER/data`:
> *"Both named volumes must store their data inside `/home/login/data` on the host machine."*

However, storing a database and WordPress files might push you over the `$HOME` quota. The standard workaround accepted by evaluators is to create the actual storage folder in `/sgoinfre` and create a **symbolic link (symlink)** to it in your home directory:

```bash
# 1. Create the actual storage in sgoinfre
mkdir -p /sgoinfre/$USER/data/mariadb
mkdir -p /sgoinfre/$USER/data/wordpress

# 2. Create a symlink in your home folder so Docker accesses it at the required path
ln -s /sgoinfre/$USER/data /home/$USER/data
```
*Note: Because `/sgoinfre` is wiped periodically, your database and WordPress site will be reset when you switch machines. This is perfectly normal and expected for this project.*

---

## 5. Recreate Your Secrets & `.env`

For security reasons, `.env` and the `secrets/` directory **must never be pushed to Git**. When you pull your repo on the school PC, these files will be missing. 

### Create `.env` in `srcs/`
```bash
cd ~/Projects/M5/Inception/srcs
touch .env
# Open .env in your editor and add your variables (DOMAIN_NAME, DB names, etc.)
```

### Recreate Secrets in `secrets/`
```bash
cd ~/Projects/M5/Inception/secrets
echo "wp_user_pass123" > db_password.txt
echo "wp_root_pass123" > db_root_password.txt
echo "wp_chief:chief_pass123" > credentials.txt
echo "wp_editor:editor_pass123" >> credentials.txt
```

---

Once these steps are complete, your new machine is fully ready. Navigate to your project root in your `$HOME` directory and run your `Makefile` to launch the infrastructure!
