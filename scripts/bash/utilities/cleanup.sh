#!/bin/bash
# Cleanup old files

LOG_FILE="/var/log/cleanup.log"
DAYS_TO_KEEP=30

{
  echo "=== INICIO LIMPIEZA $(date) ==="
  
  # 1. Cleanup old logs
  find /var/log -name "*.log" -mtime +$DAYS_TO_KEEP -delete
  
  # 2. Temp files
  rm -rf /tmp/* /var/tmp/*
  
  echo "=== FIN LIMPIEZA $(date) ==="
} >> $LOG_FILE 2>&1