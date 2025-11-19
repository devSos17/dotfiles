.PHONY: install uninstall start stop restart enable disable status test test-notify clean help

SYSTEM_DIR := /etc/nut
CONFIG_FILES := ups.conf nut.conf upsd.conf upsd.users upsmon.conf upssched.conf
SCRIPT_FILES := upssched-cmd
SERVICE_NAME := cyberpower

help:
	@echo "NUT Configuration Makefile"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  install    - Copiar configuración a $(SYSTEM_DIR)"
	@echo "  start      - Iniciar servicios de NUT"
	@echo "  stop       - Detener servicios de NUT"
	@echo "  restart    - Reiniciar servicios de NUT"
	@echo "  enable     - Habilitar servicios en el arranque"
	@echo "  disable    - Deshabilitar servicios en el arranque"
	@echo "  status      - Ver estado de los servicios"
	@echo "  test        - Ver datos del UPS"
	@echo "  test-notify - Probar notificaciones de escritorio"
	@echo "  uninstall   - Restaurar configuración original"
	@echo "  clean       - Limpiar archivos temporales"

install:
	@echo "Instalando configuración de NUT..."
	@for file in $(CONFIG_FILES); do \
		echo "  Copiando $$file..."; \
		sudo cp $$file $(SYSTEM_DIR)/$$file; \
	done
	@for file in $(SCRIPT_FILES); do \
		echo "  Copiando script $$file..."; \
		sudo cp $$file $(SYSTEM_DIR)/$$file; \
		sudo chmod 755 $(SYSTEM_DIR)/$$file; \
	done
	@echo "Configurando permisos..."
	@sudo chmod 644 $(SYSTEM_DIR)/ups.conf
	@sudo chmod 644 $(SYSTEM_DIR)/nut.conf
	@sudo chmod 640 $(SYSTEM_DIR)/upsd.conf
	@sudo chmod 640 $(SYSTEM_DIR)/upsd.users
	@sudo chmod 640 $(SYSTEM_DIR)/upsmon.conf
	@sudo chmod 644 $(SYSTEM_DIR)/upssched.conf
	@sudo chown root:nut $(SYSTEM_DIR)/upsd.conf
	@sudo chown root:nut $(SYSTEM_DIR)/upsd.users
	@sudo chown root:nut $(SYSTEM_DIR)/upsmon.conf
	@if ! groups $$USER | grep -q '\bnut\b'; then \
		echo "Agregando usuario al grupo nut..."; \
		sudo usermod -a -G nut $$USER; \
		echo "⚠️  Necesitarás logout/login para que el grupo tenga efecto"; \
	fi
	@echo "✓ Configuración instalada"

start:
	@echo "Iniciando servicios de NUT..."
	@sudo systemctl start nut-driver@$(SERVICE_NAME)
	@sudo systemctl start nut-server
	@sudo systemctl start nut-monitor
	@echo "✓ Servicios iniciados"

stop:
	@echo "Deteniendo servicios de NUT..."
	@sudo systemctl stop nut-monitor
	@sudo systemctl stop nut-server
	@sudo systemctl stop nut-driver@$(SERVICE_NAME)
	@echo "✓ Servicios detenidos"

restart: stop start

enable:
	@echo "Habilitando servicios en el arranque..."
	@sudo systemctl enable nut-driver@$(SERVICE_NAME)
	@sudo systemctl enable nut-server
	@sudo systemctl enable nut-monitor
	@echo "✓ Servicios habilitados"

disable:
	@echo "Deshabilitando servicios en el arranque..."
	@sudo systemctl disable nut-monitor
	@sudo systemctl disable nut-server
	@sudo systemctl disable nut-driver@$(SERVICE_NAME)
	@echo "✓ Servicios deshabilitados"

status:
	@echo "Estado de los servicios de NUT:"
	@echo ""
	@sudo systemctl status nut-driver@$(SERVICE_NAME) --no-pager || true
	@echo ""
	@sudo systemctl status nut-server --no-pager || true
	@echo ""
	@sudo systemctl status nut-monitor --no-pager || true

test:
	@echo "Datos del UPS:"
	@upsc $(SERVICE_NAME) || echo "Error: UPS no disponible. ¿Instalaste y arrancaste los servicios?"

test-notify:
	@./test-notifications.sh

uninstall:
	@echo "⚠️  Esto detendrá los servicios y restaurará la configuración por defecto"
	@read -p "¿Continuar? [y/N] " confirm && [ "$$confirm" = "y" ] || exit 1
	@$(MAKE) stop
	@$(MAKE) disable
	@echo "✓ Servicios detenidos y deshabilitados"

clean:
	@echo "Limpiando archivos temporales..."
	@rm -f *~
	@echo "✓ Limpieza completada"
