
# n8n Docker Setup with SSL, PostgreSQL, Traefik

🚀 Fully automated setup of [n8n](https://n8n.io) on a DigitalOcean droplet (or any VPS) with:

- Docker + Docker Compose
- PostgreSQL database for persistent workflows
- Traefik for reverse proxy and HTTPS (Let's Encrypt)
- Firewall with UFW (ports 22, 80, 443)
- Optional Swap file (for low-memory VPS)

---

## ⚙️ Features

- [x] Easy one-command setup via `setup-n8n.sh`
- [x] HTTPS enabled out of the box via Let's Encrypt
- [x] Postgres for database persistence
- [x] Auto-restart on reboot or failure
- [x] Password protection (basic auth)

---

## 📦 Installation

### 1. Clone the repo

```bash
git clone https://github.com/your-username/n8n-docker-setup.git
cd n8n-docker-setup
```

### 2. Edit and configure the script

Open `setup-n8n.sh` and adjust the following variables at the top:

```bash
DOMAIN="n8n.example.com"             # Your domain
EMAIL="you@example.com"             # Your email for Let's Encrypt
POSTGRES_PASSWORD="your_db_password" # Secure Postgres password
N8N_PASSWORD="your_n8n_password"     # n8n admin password
```

### 3. Run the setup script

```bash
chmod +x setup-n8n.sh
./setup-n8n.sh
```

---

## 🌐 Usage

- Access n8n: `https://your-domain.com`
- Default login:
  - **User**: `admin`
  - **Password**: (what you set in `N8N_PASSWORD`)

---

## 🔐 Security

- UFW enabled (only SSH, HTTP, HTTPS allowed)
- Basic Auth enabled for n8n
- Automatic SSL via Traefik + Let's Encrypt

---

## 🧹 Maintenance

| Task                   | Command                          |
|-----------------------|----------------------------------|
| Start services         | `docker-compose up -d`            |
| Stop services          | `docker-compose down`             |
| Restart services       | `docker-compose restart`          |
| Update images          | `docker-compose pull && docker-compose up -d` |
| Check logs             | `docker-compose logs -f`          |

---

## 📁 Data Persistence

- `n8n_data/`: n8n config and workflows
- `postgres_data/`: PostgreSQL database files
- `letsencrypt/`: SSL certs from Let's Encrypt

---

## ✅ License

MIT License
