#!/bin/bash
# =============================================================================
# ShopMicro - EC2 User Data Bootstrap Script
# Runs once on first launch. All output is logged to /var/log/userdata.log
# =============================================================================
exec > /var/log/userdata.log 2>&1
echo "=== ShopMicro Deploy Start: $(date) ==="

# ── 1. Swap Space (critical for t3.micro — only 1GB RAM) ──────────────────────
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
sysctl vm.swappiness=60
echo "✔ Swap 2GB enabled"

# ── 2. System Dependencies ────────────────────────────────────────────────────
apt-get update -y
apt-get install -y docker.io git curl unzip
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Install Docker Compose v2 standalone binary (works on ALL Ubuntu versions)
COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)"
curl -sSL "$COMPOSE_URL" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
echo "✔ Docker Compose installed: $(/usr/local/bin/docker-compose version)"

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
echo "✔ Docker & AWS CLI installed"

# ── 3. Clone Application ──────────────────────────────────────────────────────
cd /home/ubuntu
git clone https://github.com/3MR-MLops/web-app.git
cd web-app/web-app/ecommerce-microservices
echo "✔ Repository cloned at: $(pwd)"

# ── 4. Create .env File ───────────────────────────────────────────────────────
cat > .env << 'EOF'
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=Amr123
MONGO_URI=mongodb://admin:Amr123@mongodb:27017/admin?authSource=admin
POSTGRES_USER=postgres
POSTGRES_PASSWORD=${db_password}
POSTGRES_DB=payment_service_db
JWT_SECRET=${db_password}
REDIS_HOST=redis
S3_BACKUP_BUCKET=${s3_bucket}
EOF
echo "✔ .env created"

# ── 5. Start Infrastructure Services First (DBs, Cache) ───────────────────────
echo ">>> Starting infrastructure services..."
docker-compose up -d mongodb redis db
sleep 20
echo "✔ DBs & Redis up"

# ── 6. Build Nginx (serves frontend immediately → ALB health check passes) ────
echo ">>> Building nginx..."
docker-compose build nginx
docker-compose up -d nginx
echo "✔ Nginx up"

# Wait and confirm nginx is serving
sleep 5
HTTP_CODE=$(curl -s -I http://localhost | head -1 | awk '{print $2}' || echo "000")
echo ">>> Nginx health check: HTTP $HTTP_CODE"

# ── 7. Build Backend Services Sequentially (save RAM on t3.micro) ─────────────
for service in user-service catalog-services cart-services order-services payment-service; do
  echo ">>> Building: $service"
  docker-compose build "$service"
  docker-compose up -d "$service"
  sleep 15
done

echo "✔ All backend services started"

# ── 8. Final reconciliation ────────────────────────────────────────────────────
docker-compose up -d
echo "✔ docker-compose up -d complete"

# ── 9. Seed Products (wait for catalog to be ready) ───────────────────────────
echo ">>> Waiting for catalog service to be ready..."
for i in $(seq 1 12); do
  sleep 10
  HTTP=$(curl -s -I http://localhost/api/products | head -1 | awk '{print $2}' || echo "000")
  echo "    Attempt $i: /api/products → HTTP $HTTP"
  if [ "$HTTP" = "200" ]; then
    curl -s -X POST http://localhost/api/products/seed
    echo "✔ Catalog seeded successfully"
    break
  fi
done

# ── 10. Show running containers ────────────────────────────────────────────────
docker-compose ps
echo "=== ShopMicro Deploy Complete: $(date) ==="

# ── 11. Setup MongoDB → S3 Backup Cron (every 6 hours) ───────────────────────
cat > /usr/local/bin/backup-mongo.sh << 'BACKUP_EOF'
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%dT%H-%M-%S)
BUCKET="${s3_bucket}"
COMPOSE_DIR=/home/ubuntu/web-app/web-app/ecommerce-microservices

cd $COMPOSE_DIR
CONTAINER=$(docker-compose ps -q mongodb 2>/dev/null | head -1)
if [ -z "$CONTAINER" ]; then
  echo "[$TIMESTAMP] MongoDB container not found, skipping backup"
  exit 1
fi

docker exec "$CONTAINER" \
  mongodump --uri="mongodb://admin:Amr123@localhost:27017/admin?authSource=admin" \
  --archive --gzip 2>/dev/null > "/tmp/mongo-backup-$TIMESTAMP.gz"

aws s3 cp "/tmp/mongo-backup-$TIMESTAMP.gz" \
  "s3://$BUCKET/mongodb-backups/mongo-backup-$TIMESTAMP.gz"

rm -f "/tmp/mongo-backup-$TIMESTAMP.gz"
echo "[$TIMESTAMP] Backup → s3://$BUCKET/mongodb-backups/mongo-backup-$TIMESTAMP.gz"
BACKUP_EOF

chmod +x /usr/local/bin/backup-mongo.sh
(crontab -l 2>/dev/null; echo "0 */6 * * * /usr/local/bin/backup-mongo.sh >> /var/log/mongo-backup.log 2>&1") | crontab -
echo "✔ MongoDB S3 backup cron configured (every 6h)"