#!/bin/bash
# Automated MariaDB Backup Script

BACKUP_DIR="/opt/mariadb-backups"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DATABASES=("company_db" "inventory_db")
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR/$DATE"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$BACKUP_DIR/backup.log"
}

log_message "Starting automated backup"

for db in "${DATABASES[@]}"; do
    if mysqldump --defaults-extra-file=/root/.my.cnf --single-transaction --routines --triggers "$db" \
        | gzip > "$BACKUP_DIR/$DATE/${db}_${TIMESTAMP}.sql.gz"; then
        log_message "Successfully backed up $db"
    else
        log_message "ERROR: Failed to back up $db"
        exit 1
    fi
done

log_message "Cleaning up backups older than $RETENTION_DAYS days"
find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null

log_message "Backup process completed successfully"
