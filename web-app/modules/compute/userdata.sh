#!/bin/bash
# =============================================================================
# ShopMicro - EC2 Fast Bootstrap (from Golden Image)
# =============================================================================
exec > /var/log/userdata.log 2>&1
echo "=== ShopMicro Start from AMI: $(date) ==="

# ── 1. Create .env File — Using fresh variables ───────────────────────────────
# Note: Code is already pre-cloned in /home/ubuntu/web-app from AMI
cd /home/ubuntu/web-app/web-app/ecommerce-microservices

cat > .env << EOF
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=Amr123
MONGO_URI=mongodb://admin:Amr123@mongodb:27017/admin?authSource=admin
POSTGRES_USER=postgres
POSTGRES_PASSWORD=${db_password}
POSTGRES_DB=payment_service_db
JWT_SECRET=${db_password}
REDIS_HOST=redis
S3_BACKUP_BUCKET=${s3_bucket}
GF_ROOT_URL=http://${alb_dns}/grafana/
EOF
echo "✔ .env updated"

# ── 2. Start Services ─────────────────────────────────────────────────────────
# Everything is already built in the AMI, so we just 'up' it.
echo ">>> Starting services from pre-built images..."
docker-compose up -d 

echo "✔ Services started"

# ── 3. Seed Products (One-time) ───────────────────────────────────────────────
sleep 30
curl -s -X POST http://localhost/api/products/seed
echo "✔ Catalog seeded"

echo "=== ShopMicro Deploy Complete: $(date) ==="