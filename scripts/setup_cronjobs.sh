# Backups diarios a las 1AM
(crontab -l 2>/dev/null; echo "0 1 * * * $SCRIPTS_DIR/bash/backups/s3_sync.sh >> /var/log/s3_backup.log 2>&1") | crontab -

# Auditoría de seguridad semanal (Lunes 3AM)
(crontab -l 2>/dev/null; echo "0 3 * * 1 $SCRIPTS_DIR/bash/utilities/security_audit.sh") | crontab -

# Análisis de logs cada 6 horas
(crontab -l 2>/dev/null; echo "0 */6 * * * $SCRIPTS_DIR/bash/monitoring/log_analyzer.sh") | crontab -

# Limpieza mensual (Día 1 a las 5AM)
(crontab -l 2>/dev/null; echo "0 5 1 * * $SCRIPTS_DIR/bash/utilities/cleanup_resources.sh") | crontab -