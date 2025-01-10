#!/bin/bash

set -e

# Update package index
sudo apt-get update

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt-get install -y docker.io
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo apt-get install -y docker-compose
fi

# Create directory for Node Exporter setup
INSTALL_DIR="$HOME/node_exporter_setup"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Create a docker-compose.yml for Node Exporter
cat > docker-compose.yml <<'EOF'
version: '3.8'
services:
  node_exporter:
    image: prom/node-exporter:latest
    container_name: node_exporter
    restart: unless-stopped
    network_mode: host
    pid: host
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
EOF

# Start Node Exporter using Docker Compose
sudo docker-compose up -d

echo "Node Exporter is now running in a Docker container."
