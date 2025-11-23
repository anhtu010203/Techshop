#!/bin/bash
set -e

echo "Bắt đầu deploy lên AWS ..."


REPO_URL="https://github.com/anhtu010203/Techshop"  
# =============================================

sudo apt update -y
sudo apt install docker.io docker-compose git curl -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Cài Caddy 
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update -y
sudo apt install caddy -y

# Clone repo 
cd /home/ubuntu
git clone $REPO_URL techshop-backend || (cd techshop-backend && git pull)

cd techshop-backend

# Build Docker image
docker build -t techshop-backend .

# Dừng container cũ nếu có
docker stop techshop-app || true
docker rm techshop-app || true

# Chạy container với env Neon
docker run -d \
  --name techshop-app \
  --restart unless-stopped \
  -p 80:8080 -p 443:8080 \
  -e SPRING_DATASOURCE_URL="jdbc:postgresql://ep-rapid-field-a1h02j06-pooler.ap-southeast-1.aws.neon.tech:5432/neondb?sslmode=require&channelBinding=require" \
  -e SPRING_DATASOURCE_USERNAME="neondb_owner" \
  -e SPRING_DATASOURCE_PASSWORD="npg_hMoedL5gYaB7" \
  -e SPRING_JPA_HIBERNATE_DDL_AUTO="validate" \
  -e JWT_SECRET="techshop-jwt-secret-key-2025-very-very-long-and-secure" \
  techshop-backend

# Cấu hình Caddy tự động cấp SSL + proxy
sudo tee /etc/caddy/Caddyfile > /dev/null <<EOF
{
    auto_https
}

:80 {
    reverse_proxy localhost:8080
}

:443 {
    reverse_proxy localhost:8080
}
EOF

sudo systemctl restart caddy

echo "Deploy thành công!"
echo "Truy cập ngay:"
echo "→ http://$(curl -s ifconfig.me)"
echo "→ https://$(curl -s ifconfig.me)"
echo "Swagger UI: https://$(curl -s ifconfig.me)/swagger-ui.html"
