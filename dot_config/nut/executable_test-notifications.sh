#!/bin/bash
# Script para probar las notificaciones del UPS

echo "Probando notificaciones del UPS..."
echo ""

echo "1. Simulando: Electricidad restaurada (ONLINE)"
sudo /etc/nut/upssched-cmd online
sleep 3

echo "2. Simulando: UPS en batería (ONBATT)"
sudo /etc/nut/upssched-cmd onbatt
sleep 3

echo "3. Simulando: Batería baja (LOWBATT)"
sudo /etc/nut/upssched-cmd lowbatt
sleep 3

echo "4. Simulando: Comunicación OK (COMMOK)"
sudo /etc/nut/upssched-cmd commok
sleep 2

echo ""
echo "✓ Pruebas completadas. Deberías haber recibido 4 notificaciones."
echo ""
echo "Para ver los logs:"
echo "  journalctl -t upssched-cmd --since '1 minute ago'"
