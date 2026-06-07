#!/usr/bin/env bash
# setup-secrets.sh — Cargar secrets en Docker Swarm
#
# Run en el VPS antes del primer deploy.
#
# Generates passwords + carga los secrets que docker-stack.yml espera.

set -euo pipefail

echo "🔐 Generando y cargando secrets en Docker Swarm..."
echo ""

# ─── Verificar que swarm esté activo ──────────────────
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
  echo "❌ Docker Swarm no está activo. Ejecutar primero:"
  echo "   docker swarm init"
  exit 1
fi

# ─── Generar passwords si no existen ──────────────────
gen_or_use() {
  local name="$1"
  if docker secret inspect "$name" >/dev/null 2>&1; then
    echo "⏭️  Secret '$name' ya existe — skip"
  else
    local value
    value=$(openssl rand -base64 32)
    echo "$value" | docker secret create "$name" -
    echo "✅ Secret '$name' creado"
  fi
}

gen_or_use "postgres_password"
gen_or_use "redis_password"
gen_or_use "jwt_secret"

# ─── DATABASE_URL (construido a partir del postgres_password) ──
if docker secret inspect "database_url" >/dev/null 2>&1; then
  echo "⏭️  Secret 'database_url' ya existe — skip"
else
  # Recuperar el postgres_password recién creado para construir URL
  echo "⚠️  Para construir DATABASE_URL necesito el postgres_password."
  read -rsp "Pegá el postgres_password aquí (no se mostrará): " PG_PWD
  echo ""
  read -rp "DB user [postgres]: " DB_USER
  DB_USER=${DB_USER:-postgres}
  read -rp "DB name: " DB_NAME

  printf "postgres://%s:%s@postgres:5432/%s" "$DB_USER" "$PG_PWD" "$DB_NAME" \
    | docker secret create database_url -
  echo "✅ Secret 'database_url' creado"
fi

echo ""
echo "🎉 Secrets cargados. Próximo paso:"
echo ""
echo "   docker stack deploy -c docker-stack.yml {{PROJECT_NAME}}"
echo ""
