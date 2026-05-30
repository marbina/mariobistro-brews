#!/bin/bash
# Mario Bistro Brews — Droplet Deploy Script
# Run as root on Ubuntu 22.04
# Usage: bash deploy.sh

set -e
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Mario Bistro Brews — Server Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 1. Update system
apt update && apt upgrade -y

# 2. Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# 3. Install PM2 globally
npm install -g pm2

# 4. Install nginx
apt install -y nginx

# 5. Install certbot for SSL
apt install -y certbot python3-certbot-nginx

# 6. Create app directory
mkdir -p /var/www/mariobistro
cd /var/www/mariobistro

# 7. Copy files (run from where you uploaded them)
# scp -r mariobistro-server/* root@YOUR_DROPLET_IP:/var/www/mariobistro/

# 8. Install dependencies
npm install

# 9. Load env vars
set -a
source .env
set +a

# 10. Start with PM2
pm2 start server.js --name "mariobistro" --env production
pm2 startup
pm2 save

# 11. Configure nginx reverse proxy
cat > /etc/nginx/sites-available/mariobistro << 'NGINX'
server {
    listen 80;
    server_name admin.mariobistrobrews.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX

ln -sf /etc/nginx/sites-available/mariobistro /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# 12. SSL cert (make sure DNS A record is pointing here first)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  NEXT: Point admin.mariobistrobrews.com"
echo "  A record to this droplet's IP, then run:"
echo "  certbot --nginx -d admin.mariobistrobrews.com"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "✓ Deploy complete. Admin running on port 3000."
echo "  Visit: http://YOUR_DROPLET_IP:3000 to test"
