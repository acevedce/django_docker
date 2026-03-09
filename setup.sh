#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "❌ Debes proporcionar el nombre del proyecto como parámetro."
  echo "   Ejemplo: ./setup.sh mi_proyecto"
  exit 1
fi

PROJECT_NAME="$1"
DEST_DIR="$(dirname "$PWD")/$PROJECT_NAME"

echo "📁 Creando proyecto: $PROJECT_NAME en $DEST_DIR"

# Copiar plantilla al directorio de destino
cp -R "$PWD" "$DEST_DIR"
cd "$DEST_DIR"

# Sustituir "project" por el nombre real del proyecto en docker-compose.yml
sed -i "s|POSTGRES_DB: project|POSTGRES_DB: $PROJECT_NAME|g" docker-compose.yml
sed -i "s|DB_NAME: project|DB_NAME: $PROJECT_NAME|g" docker-compose.yml
sed -i "s|postgres://django:django@db:5432/project|postgres://django:django@db:5432/$PROJECT_NAME|g" docker-compose.yml

# Crear app Django con el nombre del proyecto si no existe
if [ ! -d "./app" ]; then
  echo "🐍 Creando app Django..."
  mkdir -p ./app
  cat > ./app/requirements.txt <<EOF
Django>=4.2,<5.0
psycopg2-binary>=2.9
EOF

  # Crear proyecto Django dentro de app/
  docker run --rm -v "$DEST_DIR/app:/app" -w /app python:3.12-slim \
    sh -c "pip install -q Django && django-admin startproject $PROJECT_NAME ."

  # Ajustar settings.py para usar PostgreSQL
  SETTINGS_FILE="./app/$PROJECT_NAME/settings.py"

  # Reemplazar DATABASES en settings.py
  python3 - <<PYEOF
import re

with open('$SETTINGS_FILE', 'r') as f:
    content = f.read()

db_block = """DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': '$PROJECT_NAME',
        'USER': 'django',
        'PASSWORD': 'django',
        'HOST': 'db',
        'PORT': '5432',
    }
}"""

content = re.sub(
    r"DATABASES\s*=\s*\{.*?\}\s*\}",
    db_block,
    content,
    flags=re.DOTALL
)

# Añadir ALLOWED_HOSTS si está vacío
content = content.replace("ALLOWED_HOSTS = []", "ALLOWED_HOSTS = ['*']")

with open('$SETTINGS_FILE', 'w') as f:
    f.write(content)

print("✅ settings.py configurado correctamente")
PYEOF

fi

# Ajustar permisos del volumen de PostgreSQL
echo "🔧 Ajustando permisos..."
sudo chown -R 999:999 "$DEST_DIR" 2>/dev/null || true

echo ""
echo "✅ Proyecto '$PROJECT_NAME' creado en: $DEST_DIR"
echo ""
echo "👉 Para arrancar:"
echo "   cd $DEST_DIR"
echo "   ./launch.sh"
