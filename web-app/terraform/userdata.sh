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
echo "✔ Swap enabled"

# ── 2. System Dependencies ────────────────────────────────────────────────────
apt-get update -y
apt-get install -y docker.io git awscli
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
echo "✔ Docker installed"

# Install Docker Compose v2 plugin
mkdir -p /usr/local/lib/docker/cli-plugins
curl -sSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
echo "✔ Docker Compose installed"

# ── 3. Clone Application ──────────────────────────────────────────────────────
cd /home/ubuntu
git clone https://github.com/3MR-MLops/web-app.git
cd web-app/ecommerce-microservices
echo "✔ Repository cloned"

# ── 4. Create .env File ───────────────────────────────────────────────────────
cat > .env << 'EOF'
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=Amr123
MONGO_URI=mongodb://admin:Amr123@mongodb:27017/admin?authSource=admin
POSTGRES_USER=postgres
POSTGRES_PASSWORD=Amrsaad010900
POSTGRES_DB=payment_service_db
JWT_SECRET=Amrsaad010900
REDIS_HOST=redis
S3_BACKUP_BUCKET=${s3_bucket}
EOF
echo "✔ .env created"

# ── 5. Build & Start Services (sequential to stay within RAM limits) ──────────
echo "Building nginx first for immediate frontend availability..."
docker compose build nginx
docker compose up -d nginx

echo "Starting backend services sequentially..."
for service in mongodb redis db user-service catalog-services cart-services order-services payment-service; do
  echo "Starting: $service"
  docker compose up -d "$service"
  sleep 10
done

# Final reconciliation — start anything still stopped
docker compose up -d
echo "✔ All services started"

# ── 6. Seed Products ──────────────────────────────────────────────────────────
sleep 20
echo "Seeding catalog with sample products..."
curl -s -X POST http://localhost/api/products/seed || true
echo "✔ Catalog seeded"

# ── 7. Setup MongoDB → S3 Backup Cron (runs every 6 hours) ───────────────────
cat > /usr/local/bin/backup-mongo.sh << 'BACKUP_EOF'
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%dT%H-%M-%S)
BUCKET="${s3_bucket}"

echo "[$TIMESTAMP] Starting MongoDB backup..."

# Dump from the running MongoDB container
docker exec ecommerce-microservices-mongodb-1 \
  mongodump --uri="mongodb://admin:Amr123@localhost:27017/admin?authSource=admin" \
  --out="/tmp/mongodump-$TIMESTAMP" 2>/dev/null

# Compress
tar -czf "/tmp/mongo-backup-$TIMESTAMP.tar.gz" -C /tmp "mongodump-$TIMESTAMP"

# Upload to S3
aws s3 cp "/tmp/mongo-backup-$TIMESTAMP.tar.gz" \
  "s3://$BUCKET/mongodb-backups/mongo-backup-$TIMESTAMP.tar.gz"

# Cleanup local temp files
rm -rf "/tmp/mongodump-$TIMESTAMP" "/tmp/mongo-backup-$TIMESTAMP.tar.gz"

echo "[$TIMESTAMP] Backup uploaded to s3://$BUCKET/mongodb-backups/"
BACKUP_EOF

chmod +x /usr/local/bin/backup-mongo.sh

# Add cron job — every 6 hours
(crontab -l 2>/dev/null; echo "0 */6 * * * /usr/local/bin/backup-mongo.sh >> /var/log/mongo-backup.log 2>&1") | crontab -
echo "✔ MongoDB backup cron job configured (every 6 hours → s3://${s3_bucket})"

echo "=== ShopMicro Deploy Complete: $(date) ==="