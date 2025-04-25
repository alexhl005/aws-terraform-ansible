#!/bin/bash
# Cleanup old files, containers, and snapshots

LOG_FILE="/var/log/cleanup.log"
DAYS_TO_KEEP=30

{
  echo "=== INICIO LIMPIEZA $(date) ==="
  
  # 1. Cleanup old logs
  find /var/log -name "*.log" -mtime +$DAYS_TO_KEEP -delete
  
  # 2. Docker cleanup
  if command -v docker &>/dev/null; then
    docker system prune -af --volumes
  fi
  
  # 3. AWS snapshots cleanup (older than 30d)
  SNAPSHOTS=$(aws ec2 describe-snapshots --owner-ids self --query "Snapshots[?StartTime<=\`$(date --date="-$DAYS_TO_KEEP days" +%Y-%m-%d)\`].SnapshotId" --output text)
  for snap in $SNAPSHOTS; do
    aws ec2 delete-snapshot --snapshot-id $snap
    echo "Deleted snapshot: $snap"
  done
  
  # 4. Temp files
  rm -rf /tmp/* /var/tmp/*
  
  echo "=== FIN LIMPIEZA $(date) ==="
} >> $LOG_FILE 2>&1