#!/bin/bash

set -e

cd /home/deploy/projects/vextra

echo "===> Updating source code..."
git fetch origin
git reset --hard origin/main

echo "===> Creating database backup..."
./scripts/backup_db.sh

echo "===> Building and starting containers..."
docker compose up -d --build

echo "===> Waiting for application..."

for i in {1..30}; do
  if curl -fs https://vextra.cloud/health > /dev/null; then
    echo "Application is healthy."
    break
  fi

  echo "Waiting..."
  sleep 2

  if [ "$i" -eq 30 ]; then
    echo "Health check failed."
    exit 1
  fi
done

echo "===> Cleaning old Docker images..."
docker image prune -f

echo "===> Deployment completed successfully."