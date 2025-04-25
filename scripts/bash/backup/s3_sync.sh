#!/bin/bash
# Sync local backups to S3 with lifecycle policy

BACKUP_DIR="/backups"
S3_BUCKET="s3://your-backup-bucket"
LOG_FILE="/var/log/s3_backup.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

{
  echo "=== Inicio Sync S3 $(date) ==="
  
  # 1. Sync backups
  aws s3 sync $BACKUP_DIR $S3_BUCKET --delete --exclude "*" --include "*.gz" --no-progress
  
  # 2. Apply lifecycle policy (30d standard, 90d glacier)
  aws s3api put-object-tagging --bucket your-backup-bucket --key backups/ \
    --tagging '{"TagSet": [{"Key": "expire_rule", "Value": "30d_standard_90d_glacier"}]}'
    
  echo "=== Fin Sync S3 $(date) ==="
  echo "Espacio utilizado en S3:"
  aws s3 ls $S3_BUCKET --recursive --human-readable --summarize | tail -n 2
} >> $LOG_FILE 2>&1