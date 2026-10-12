#!/usr/bin/env bash
# Backup diário do Postgres (pg_dump comprimido) em ~/backups, mantendo os últimos 14.
# Agendar na VM:  crontab -e  ->  30 3 * * * /home/ubuntu/work/confectionery-suite/confectionery-infra/nuvem/backup-banco.sh
set -euo pipefail
DEST="${BACKUP_DIR:-$HOME/backups}"
mkdir -p "$DEST"
ARQ="$DEST/confectionery-$(date +%Y%m%d-%H%M).sql.gz"
docker exec postgres-confectionery-db sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' | gzip > "$ARQ"
ls -1t "$DEST"/confectionery-*.sql.gz | tail -n +15 | xargs -r rm --
echo "Backup: $ARQ"
