#!/bin/bash
# Sync WordPress uploads to S3 with directory structure preservation

WP_UPLOADS_DIR="/var/www/html/wp-content/uploads"
S3_BUCKET="s3://your-backup-bucket"
LOG_FILE="/var/log/wp_uploads_s3_sync.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

{
  echo "=== Inicio Sync WP Uploads S3 $(date) ==="
  
  # 1. Sync wp-content/uploads directory, preserving year/month structure
  aws s3 sync $WP_UPLOADS_DIR $S3_BUCKET \
    --exclude "*" \
    --include "*/[0-9][0-9][0-9][0-9]/[0-9][0-9]/*" \
    --no-progress
  
  # 2. Apply lifecycle policy if needed (adjust as required)
  # This will tag all synced objects with the lifecycle policy
  for year_month_dir in $(find $WP_UPLOADS_DIR -maxdepth 2 -type d -regextype sed -regex ".*/[0-9]\{4\}/[0-9]\{2\}$"); do
    year=$(basename $(dirname $year_month_dir))
    month=$(basename $year_month_dir)
    
    aws s3api put-object-tagging \
      --bucket your-backup-bucket \
      --key "wp-uploads/$year/$month/" \
      --tagging '{"TagSet": [{"Key": "expire_rule", "Value": "30d_standard_90d_glacier"}]}'
  done
    
  echo "=== Fin Sync WP Uploads S3 $(date) ==="
  echo "Resumen de espacio utilizado:"
  aws s3 ls $S3_BUCKET --recursive --human-readable --summarize | tail -n 2
} >> $LOG_FILE 2>&1