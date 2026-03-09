#!/bin/bash

set -e

echo "🚀 Levantando servicios Django + PostgreSQL..."
docker-compose build
docker-compose up -d

echo ""
echo "✅ Contenedores en ejecución:"
docker-compose ps

echo ""
echo "🌍 Accede a Django en: http://localhost:8000"
