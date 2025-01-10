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

# Create directory for central monitoring setup
INSTALL_DIR="$HOME/central_monitoring_setup"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Create a default Prometheus configuration file
cat > prometheus.yml <<'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets:
          - '13.49.245.182:9100'   # Test 1
          - '51.20.133.61:9100'     # Test 2 (local)
EOF

# Create a docker-compose.yml for Prometheus & Grafana
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  prometheus_data:
  grafana_data:
EOF

# Start Prometheus and Grafana using Docker Compose
sudo docker-compose up -d

echo "Prometheus and Grafana are now running."
echo "Access Prometheus at http://localhost:9090 and Grafana at http://localhost:3000"
