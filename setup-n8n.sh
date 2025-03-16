
#!/bin/bash

# === Variables you need to customize ===
DOMAIN="n8n.example.com"
EMAIL="you@example.com"  # Your email for Let's Encrypt
POSTGRES_PASSWORD="your_strong_postgres_password"
N8N_PASSWORD="your_strong_n8n_password"

# === Update system and install dependencies ===
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl ufw

# === Install Docker & Docker Compose ===
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
sudo curl -L "https://github.com/docker/compose/releases/download/2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# === Create Swap Space (1G) ===
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# === Setup UFW Firewall ===
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# === Prepare Docker Compose Directory ===
mkdir -p ~/n8n-docker/{letsencrypt,n8n_data,postgres_data}
cd ~/n8n-docker

# === Create docker-compose.yml ===
cat <<EOF > docker-compose.yml

services:
  traefik:
    image: traefik:v2.11
    command:
      - "--api.insecure=false"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.myresolver.acme.email=${EMAIL}"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
    restart: always

  postgres:
    image: postgres:15
    restart: always
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: n8n
    volumes:
      - ./postgres_data:/var/lib/postgresql/data

  n8n:
    image: n8nio/n8n:latest
    restart: always
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - N8N_HOST=${DOMAIN}
      - WEBHOOK_URL=https://${DOMAIN}
      - NODE_ENV=production
    volumes:
      - ./n8n_data:/home/node/.n8n
    depends_on:
      - postgres
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.n8n.rule=Host(\`${DOMAIN}\`)"
      - "traefik.http.routers.n8n.entrypoints=websecure"
      - "traefik.http.routers.n8n.tls.certresolver=myresolver"
EOF

# === Launch Docker Compose ===
docker-compose up -d

# === Final Message ===
echo "=========================================="
echo "🎉 n8n is now running at https://${DOMAIN}"
echo "🔑 Login user: admin"
echo "🔒 Login password: (the one you set in N8N_PASSWORD)"
echo "🚀 To manage n8n: cd ~/n8n-docker && docker-compose [up/down/restart]"
echo "✅ Firewall enabled (ports 22, 80, 443)"
echo "=========================================="
