#!/usr/bin/env bash
# restore.sh — Restaurar DB desde backup
#
# Usage:
#   ./restore.sh                    # restaura el backup MÁS RECIENTE local
#   ./restore.sh db-2026-06-01.sql.gz  # restaura un backup específico
#   ./restore.sh --from-b2 2026-06-01  # descarga de B2 y restaura
#
# ⚠️ CUIDADO: esto BORRA la DB actual y la reemplaza con el backup.
#    Asegurate de:
#    1. Parar la app primero (docker service scale {{stack}}_app=0)
#    2. Hacer un snapshot del estado actual por si necesitás rollback

set -euo pipefail

source /opt/scripts/.env.backup

# ─── Determinar qué backup restaurar ────────────────────
if [[ "${1:-}" == "--from-b2" ]]; then
  DATE="${2:?usage: restore.sh --from-b2 YYYY-MM-DD}"
  echo "Descargando db-${DATE}.sql.gz desde B2..."
  b2 download-file-by-name "${B2_BUCKET}" "db/db-${DATE}.sql.gz" "/tmp/db-${DATE}.sql.gz"
  BACKUP_FILE="/tmp/db-${DATE}.sql.gz"
elif [[ -n "${1:-}" ]]; then
  BACKUP_FILE="${BACKUP_DIR}/$1"
  [[ -f "${BACKUP_FILE}" ]] || { echo "❌ No existe: ${BACKUP_FILE}"; exit 1; }
else
  BACKUP_FILE=$(ls -t "${BACKUP_DIR}"/db-*.sql.gz | head -1)
  echo "Usando backup más reciente: ${BACKUP_FILE}"
fi

# ─── Confirmar ──────────────────────────────────────────
echo ""
echo "⚠️  ESTO VA A BORRAR LA DB '${POSTGRES_DB}' Y RESTAURAR DESDE:"
echo "    ${BACKUP_FILE}"
echo ""
read -r -p "Estás SEGURO? (escribir 'yes restore' para continuar): " CONFIRM

if [[ "${CONFIRM}" != "yes restore" ]]; then
  echo "Cancelado."
  exit 0
fi

# ─── Snapshot defensivo del estado actual ───────────────
SAFETY_BACKUP="${BACKUP_DIR}/safety-pre-restore-$(date -u +%Y-%m-%d_%H-%M-%S).sql.gz"
echo "Creando snapshot defensivo en ${SAFETY_BACKUP}..."
docker exec "${POSTGRES_CONTAINER}" \
  pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
  | gzip > "${SAFETY_BACKUP}"

# ─── Drop + recreate DB ─────────────────────────────────
echo "Dropping DB ${POSTGRES_DB}..."
docker exec "${POSTGRES_CONTAINER}" \
  psql -U "${POSTGRES_USER}" -c "DROP DATABASE IF EXISTS ${POSTGRES_DB};"

echo "Creating DB ${POSTGRES_DB}..."
docker exec "${POSTGRES_CONTAINER}" \
  psql -U "${POSTGRES_USER}" -c "CREATE DATABASE ${POSTGRES_DB};"

# ─── Restore ────────────────────────────────────────────
echo "Restoring desde ${BACKUP_FILE}..."
gunzip -c "${BACKUP_FILE}" | docker exec -i "${POSTGRES_CONTAINER}" \
  psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"

# ─── Verificar ──────────────────────────────────────────
echo ""
echo "Verificando — count de tablas:"
docker exec "${POSTGRES_CONTAINER}" \
  psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "\dt" | tail -3

echo ""
echo "✅ Restore completado."
echo ""
echo "Snapshot defensivo guardado en: ${SAFETY_BACKUP}"
echo "(borralo cuando confirmes que la restauración funciona)"
echo ""
echo "Próximo paso: levantar la app de nuevo:"
echo "  docker service scale {{stack}}_app=1"
