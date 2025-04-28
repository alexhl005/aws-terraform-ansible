#!/bin/bash
# Analiza logs para errores críticos

LOG_DIR="/var/log"
ERROR_PATTERNS=(
    "Out of memory"
    "Killed process"
    "segmentation fault"
    "Critical error"
)
REPORT_FILE="$LOG_DIR/wordpress_service_monitor.log"
THRESHOLD=1  # Notificar si hay más de X errores

analyze_logs() {
    local count=0
    echo "Reporte generado: $(date)" > $REPORT_FILE
    
    for pattern in "${ERROR_PATTERNS[@]}"; do
        echo "=== Patrón: $pattern ===" >> $REPORT_FILE
        grep -i "$pattern" $LOG_DIR/*.log >> $REPORT_FILE
        matches=$(grep -ci "$pattern" $LOG_DIR/*.log)
        ((count += matches))
    done
    
    if [ $count -gt $THRESHOLD ]; then
        /usr/bin/python3 ../python/monitoring/slack_reporter.py \
            "⚠️ Alto número de errores detectados: $count (Ver $REPORT_FILE)"
    fi
}

analyze_logs