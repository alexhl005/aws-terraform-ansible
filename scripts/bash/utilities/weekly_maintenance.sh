#!/bin/bash
# Tareas de mantenimiento semanal

LOG_FILE="/var/log/weekly_maintenance.log"
{
  echo "=== INICIO MANTENIMIENTO $(date) ==="
  
  # 1. Limpieza de paquetes
  apt-get autoremove -y
  
  # 2. Rotación de logs
  logrotate -f /etc/logrotate.conf
  
  # 3. Verificación de discos
  df -h
  du -sh /var/log/*
  
  # 4. Actualización de índices de búsqueda
  updatedb
  
  echo "=== FIN MANTENIMIENTO $(date) ==="
} >> $LOG_FILE 2>&1
