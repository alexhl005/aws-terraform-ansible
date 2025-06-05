#!/usr/bin/env python3
"""
Slack Reporter para Alertas de WordPress
Envía notificaciones a Slack cuando se detectan problemas con los servicios
"""

import sys
import json
import requests
from datetime import datetime

# Configuración - Cambia estos valores
SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
SITE_NAME = "Mi WordPress"
ENVIRONMENT = "prod"

# Colores para los diferentes niveles de alerta
COLORS = {
    "info": "#3498db",
    "warning": "#f39c12",
    "critical": "#e74c3c",
    "success": "#2ecc71"
}

def send_slack_alert(level, title, message):
    """Envía un mensaje a Slack"""
    
    payload = {
        "attachments": [
            {
                "color": COLORS.get(level.lower(), COLORS["info"]),
                "title": f":wordpress: {SITE_NAME} - {title}",
                "text": message,
                "fields": [
                    {
                        "title": "Entorno",
                        "value": ENVIRONMENT,
                        "short": True
                    },
                    {
                        "title": "Nivel",
                        "value": level.upper(),
                        "short": True
                    },
                    {
                        "title": "Fecha",
                        "value": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                        "short": False
                    }
                ],
                "footer": "Monitor de WordPress",
                "ts": datetime.now().timestamp()
            }
        ]
    }
    
    try:
        response = requests.post(
            SLACK_WEBHOOK_URL,
            data=json.dumps(payload),
            headers={"Content-Type": "application/json"}
        )
        return response.status_code == 200
    except Exception as e:
        print(f"Error enviando a Slack: {str(e)}", file=sys.stderr)
        return False

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Uso: slack_reporter.py [nivel] [título] [mensaje]")
        sys.exit(1)
    
    level = sys.argv[1]
    title = sys.argv[2]
    message = " ".join(sys.argv[3:])
    
    success = send_slack_alert(level, title, message)
    sys.exit(0 if success else 1)