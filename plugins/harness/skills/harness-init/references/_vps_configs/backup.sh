#!/usr/bin/env bash
# backup.sh — Backup automatizado de DB + uploads para {{PROJECT_NAME}}
#
# Cron: 0 3 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
#
# Requisitos:
#   - Docker corriendo el container postgres
#   - B2 CLI instalado y configurado (b2 authorize-account)
#   - Variables de entorno en /opt/scripts/.env.backup
#
# Variables esperadas en .env.backup:
#   POSTGRES_CONTAINER=...
#   POSTGRES_USER=...
#   POSTGRES_DB=...
#   UPLOADS_PATH=/data/{{PROJECT_NAME}}/uploads
#   B2_BUCKET=publiafy-backups
#   BACKUP_DIR=/backups
#   LOCAL_RETENTION_DAYS=30

set -euo pipefail

# ─── Cargar config ──────────────────────────────────────
source /opt/scripts/.env.backup

DATE=$(date -u +%Y-%m-%d)
TIMESTAMP=$(date -u +%Y-%m-%d_%H-%M-%S)
DB_BACKUP="${BACKUP_DIR}/db-${DATE}.sql.gz"

mkdir -p "${BACKUP_DIR}"

echo "[$(date -u +%FT%TZ)] backup start"

# ─── Backup de DB ───────────────────────────────────────
echo "[$(date -u +%FT%TZ)] dumping postgres..."
docker exec "${POSTGRES_CONTAINER}" \
  pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
  | gzip > "${DB_BACKUP}"

DB_SIZE=$(du -h "${DB_BACKUP}" | cut -f1)
echo "[$(date -u +%FT%TZ)] DB backup: ${DB_BACKUP} (${DB_SIZE})"

# Verificar que tiene contenido razonable (>10 KB)
if [[ $(stat -c%s "${DB_BACKUP}") -lt 10240 ]]; then
  echo "[$(date -u +%FT%TZ)] ⚠️  WARNING: DB backup demasiado chico (<10KB) — posible falla"
  exit 1
fi

# ─── Upload a B2 ────────────────────────────────────────
echo "[$(date -u +%FT%TZ)] uploading DB to B2..."
b2 upload-file "${B2_BUCKET}" "${DB_BACKUP}" "db/db-${DATE}.sql.gz"

# ─── Backup de uploads (rsync incremental a B2) ────────
if [[ -d "${UPLOADS_PATH}" ]]; then
  echo "[$(date -u +%FT%TZ)] syncing uploads to B2..."
  b2 sync "${UPLOADS_PATH}" "b2://${B2_BUCKET}/uploads/" --delete
fi

# ─── Cleanup local (mantener últimos N días) ───────────
echo "[$(date -u +%FT%TZ)] cleaning local backups older than ${LOCAL_RETENTION_DAYS}d..."
find "${BACKUP_DIR}" -name 'db-*.sql.gz' -mtime +${LOCAL_RETENTION_DAYS} -delete

echo "[$(date -u +%FT%TZ)] ✅ backup complete"
