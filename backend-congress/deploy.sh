#!/bin/bash

# Configuration
SERVER_USER="root"
SERVER_HOST="51.178.26.4" # Server IP address
APP_DIR="/root/AFRAN-2025/backend-congress"
LOCAL_DIR="."

echo "Starting deployment process..."

# Create necessary directories on the server
echo "Creating directories on the server..."
ssh $SERVER_USER@$SERVER_HOST "mkdir -p $APP_DIR/uploads"

# Copy application files to the server
echo "Transferring files to the server..."
rsync -avz --exclude 'node_modules' \
    --exclude '.git' \
    --exclude '.DS_Store' \
    $LOCAL_DIR/ $SERVER_USER@$SERVER_HOST:$APP_DIR/

# Copy environment variables
echo "Copying environment file..."
scp .env $SERVER_USER@$SERVER_HOST:$APP_DIR/.env

# Create systemd service file
echo "Creating systemd service file..."
ssh $SERVER_USER@$SERVER_HOST "cat > /etc/systemd/system/afran-backend.service << 'EOL'
[Unit]
Description=AFRAN 2025 Backend API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR
ExecStart=/usr/bin/node $APP_DIR/server.js
Restart=on-failure
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOL"

# Install dependencies and configure Nginx
echo "Installing dependencies and configuring services..."
ssh $SERVER_USER@$SERVER_HOST "cd $APP_DIR && \
    npm install && \
    systemctl daemon-reload && \
    systemctl enable afran-backend && \
    systemctl restart afran-backend && \
    apt update && \
    apt install -y nginx && \
    cat > /etc/nginx/sites-available/afran-backend << 'EOL'
server {
    listen 80;
    server_name 51.178.26.4;

    location / {
        proxy_pass http://localhost:8087;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Configuration pour gérer les téléchargements de fichiers volumineux
    client_max_body_size 10M;
}
EOL
    ln -sf /etc/nginx/sites-available/afran-backend /etc/nginx/sites-enabled/ && \
    nginx -t && \
    systemctl restart nginx"

# Verify status
echo "Verifying service status..."
ssh $SERVER_USER@$SERVER_HOST "systemctl status afran-backend --no-pager && \
    systemctl status nginx --no-pager"

echo "Deployment completed successfully!" 