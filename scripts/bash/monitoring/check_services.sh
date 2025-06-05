#!/bin/bash
# Monitor general de servicios y uso de CPU con notificaciones a Slack

# -------------------------
# Parámetros de configuración
# -------------------------
UMBRAL_CPU=90
LOG_FILE="/var/log/combined_services_monitor.log"
SLACK_REPORTER="/usr/local/bin/slack_reporter.py"  # Ruta al script Python

# Servicios esenciales de WordPress (monitor de estado/reinicio)
WP_SERVICES=("apache2" "php-fpm" "cron" "rsyslog")

# Servicios a vigilar por uso de CPU (restart si excede umbral)
CPU_SERVICES=("mariadb" "nginx")  # En Debian/Ubuntu sería "apache2" en lugar de "httpd"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# -------------------------
# Funciones auxiliares
# -------------------------

# Función para escribir en log con timestamp y en Slack
log() {
    local mensaje="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $mensaje" | sudo tee -a "$LOG_FILE" >/dev/null
}

# Función para reiniciar un servicio y notificar en Slack
reiniciar_servicio() {
    local servicio="$1"
    log "Intentando reiniciar $servicio..."
    if sudo systemctl restart "$servicio"; then
        log "Éxito: $servicio reiniciado correctamente"
        $SLACK_REPORTER "warning" "Servicio $servicio Reiniciado" "El servicio $servicio estaba caído/sobrecargado y se reinició automáticamente en $(date '+%Y-%m-%d %H:%M:%S')."
        return 0
    else
        log "Error: Falló al reiniciar $servicio"
        $SLACK_REPORTER "critical" "Fallo en Servicio $servicio" "El servicio $servicio no pudo reiniciarse automáticamente. ¡Se requiere intervención manual!"
        return 1
    fi
}

# -------------------------
# Inicio de monitoreo
# -------------------------
$SLACK_REPORTER "info" "Monitoreo General Iniciado" "Se inició el monitoreo combinado de servicios en $TIMESTAMP."
log "=== INICIO MONITOREO GENERAL ($TIMESTAMP) ==="

# -------------------------
# 1. Monitoreo de servicios esenciales de WordPress
# -------------------------
log "--- Monitoreo de estado de servicios WP ---"
for servicio in "${WP_SERVICES[@]}"; do
    if systemctl is-active --quiet "$servicio"; then
        log "[OK] $servicio está en ejecución"
    else
        log "[CRÍTICO] $servicio está caído - Intentando reinicio..."
        reiniciar_servicio "$servicio"
    fi
done

# -------------------------
# 2. Monitoreo de uso de CPU en otros servicios
# -------------------------
log "--- Monitoreo de uso de CPU en servicios específicos ---"
for servicio in "${CPU_SERVICES[@]}"; do
    # Verificar si está instalado/habilitado
    if ! systemctl is-enabled --quiet "$servicio" 2>/dev/null; then
        log "[WARNING] El servicio $servicio no está instalado o no está habilitado"
        continue
    fi

    # Calcular uso total de CPU para el proceso
    USO_CPU=$(ps -C "$servicio" -o %cpu --no-headers | awk '{sum+=$1} END {print sum}')
    if [ -z "$USO_CPU" ]; then
        USO_CPU=0
    fi

    # Registro de uso de CPU
    log "Servicio: $servicio - Uso de CPU: ${USO_CPU}%"

    # Si supera el umbral, reiniciar
    if (( $(echo "$USO_CPU > $UMBRAL_CPU" | bc -l) )); then
        log "[ALERTA] $servicio sobrecargado ($USO_CPU% > $UMBRAL_CPU%)"
        $SLACK_REPORTER "warning" "Alerta CPU $servicio" "El servicio $servicio excede el umbral de CPU (${USO_CPU}% > ${UMBRAL_CPU}%). Intentando reinicio..."
        reiniciar_servicio "$servicio"
    fi
done

# -------------------------
# Fin de monitoreo
# -------------------------
FIN_TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
log "=== FIN MONITOREO GENERAL ($FIN_TIMESTAMP) ==="
