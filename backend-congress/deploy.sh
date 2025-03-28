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

# Verify files were transferred
echo "Verifying files..."
ssh $SERVER_USER@$SERVER_HOST "ls -la $APP_DIR"

# Install dependencies and start the application
echo "Installing dependencies and starting the application..."
ssh $SERVER_USER@$SERVER_HOST "cd $APP_DIR && \
    npm install && \
    npm install pm2 -g && \
    pm2 delete afran-backend || true && \
    pm2 start server.js --name afran-backend && \
    pm2 save && \
    pm2 list"

echo "Deployment completed successfully!" 