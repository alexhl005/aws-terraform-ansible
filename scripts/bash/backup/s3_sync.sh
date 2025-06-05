#!/bin/bash
# Sync WordPress uploads to S3 with directory structure preservation y notificaciones a Slack

WP_UPLOADS_DIR="/var/www/html/wp-content/uploads"
S3_BUCKET="bucket_arn"
LOG_FILE="/var/log/wp_uploads_s3_sync.log"
SLACK_REPORTER="python3 ./slack_reporter.py"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

{
  echo "=== Inicio Sync WP Uploads S3 $(date) ==="

  # 1. Sync wp-content/uploads directory, preservando estructura año/mes
  aws s3 sync "$WP_UPLOADS_DIR" "$S3_BUCKET" \
    --exclude "*" \
    --include "*/[0-9][0-9][0-9][0-9]/[0-9][0-9]/*" \
    --no-progress
  SYNC_EXIT_CODE=$?
  
  if [ $SYNC_EXIT_CODE -eq 0 ]; then
    echo "[OK] Sincronización S3 completada correctamente"
    $SLACK_REPORTER "info" "Sync WP Exitoso" "La sincronización de wp-content/uploads a S3 finalizó correctamente en $(date +%Y%m%d_%H%M%S)."
  else
    echo "[ERROR] Sincronización S3 fallida"
    $SLACK_REPORTER "critical" "Sync WP Fallido" "La sincronización a S3 falló con código $SYNC_EXIT_CODE. Revisa el log: $LOG_FILE"
    # Si falla, no continuar con el tagging
    exit 1
  fi

  # 2. Aplicar lifecycle policy si es necesario (ajusta según convenga)
  for year_month_dir in $(find "$WP_UPLOADS_DIR" -maxdepth 2 -type d -regextype sed -regex ".*/[0-9]\{4\}/[0-9]\{2\}$"); do
    year=$(basename "$(dirname "$year_month_dir")")
    month=$(basename "$year_month_dir")
    
    aws s3api put-object-tagging \
      --bucket your-backup-bucket \
      --key "wp-uploads/$year/$month/" \
      --tagging '{"TagSet": [{"Key": "expire_rule", "Value": "30d_standard_90d_glacier"}]}'
    TAG_EXIT_CODE=$?
    if [ $TAG_EXIT_CODE -ne 0 ]; then
      echo "[WARNING] Falló el tagging para $year/$month"
      $SLACK_REPORTER "warning" "Tagging WP Fallido" "No se pudo aplicar tagging de lifecycle a wp-uploads/$year/$month. Código: $TAG_EXIT_CODE"
    fi
  done

  echo "=== Fin Sync WP Uploads S3 $(date) ==="
  echo "Resumen de espacio utilizado:"
  aws s3 ls "$S3_BUCKET" --recursive --human-readable --summarize | tail -n 2
} >> "$LOG_FILE" 2>&1

# Notificar fin general (si no salió con exit 1)
if [ $? -eq 0 ]; then
  SPACE_SUMMARY=$(aws s3 ls "$S3_BUCKET" --recursive --human-readable --summarize | tail -n 2 | tr '\n' ' ')
  $SLACK_REPORTER "info" "Sync WP Finalizado" "La sincronización terminó correctamente. $SPACE_SUMMARY"
fi
