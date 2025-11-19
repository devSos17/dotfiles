# NUT (Network UPS Tools) Configuration

Configuración para monitoreo del UPS CyberPower CP1500AVRLCD.

## Archivos

- `ups.conf` - Configuración del driver y detección del UPS
- `nut.conf` - Modo de operación (standalone)
- `upsd.conf` - Servidor NUT (solo localhost)
- `upsd.users` - Usuarios para acceso al servidor
- `upsmon.conf` - Monitor y configuración de shutdown automático
- `upssched.conf` - Eventos temporizados
- `upssched-cmd` - Script de notificaciones personalizadas
- `Makefile` - Gestión de instalación y servicios

## Uso

```bash
make install      # Instalar configuración a /etc/nut/
make start        # Iniciar servicios
make enable       # Habilitar en arranque
make status       # Ver estado
make test         # Ver datos del UPS
make test-notify  # Probar notificaciones
make restart      # Reiniciar servicios
```

## Notificaciones configuradas

- **ONBATT**: UPS en batería (espera 30s)
- **ONLINE**: Electricidad restaurada
- **LOWBATT**: Batería baja (<10%)
- **COMMBAD/COMMOK**: Pérdida/restauración de comunicación
- **SHUTDOWN**: Sistema apagándose
- **REPLBATT**: Batería necesita reemplazo

Las notificaciones se envían como:
- Desktop notifications (notify-send)
- Logs en syslog (journalctl -t upssched-cmd)

## Suspend/Resume

**IMPORTANTE**: Si la computadora está en suspend (sleep), NUT no puede monitorear el UPS.

### Comportamiento actual:
- NUT usa systemd sleep inhibitors para prevenir suspend cuando UPS está en batería
- Si la batería se agota durante suspend, podría haber apagado abrupto

### Recomendaciones:
1. Usa hibernate en lugar de suspend para sesiones largas
2. Configura shutdown automático después de X minutos en batería
3. Ajusta `battery.runtime.low` si es necesario

## Monitoreo en tiempo real

```bash
# Ver estado actual
upsc cyberpower

# Ver solo estado
upsc cyberpower ups.status

# Ver batería
upsc cyberpower battery.charge battery.runtime

# Ver logs de eventos
journalctl -u nut-monitor -f
journalctl -t upssched-cmd -f
```

## Comandos útiles del UPS

```bash
# Listar comandos disponibles
upscmd -l cyberpower

# Probar beeper (si está disponible)
upscmd cyberpower beeper.toggle
```

## Troubleshooting

```bash
# Ver estado de servicios
make status

# Reiniciar todo
make restart

# Ver logs
journalctl -u nut-driver@cyberpower -f
journalctl -u nut-server -f
journalctl -u nut-monitor -f
```
