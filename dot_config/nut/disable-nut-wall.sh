#!/bin/bash
# Script para deshabilitar wall messages de NUT
# Crea un wrapper para /usr/bin/wall que filtra mensajes de NUT

# Crear directorio para el wrapper
sudo mkdir -p /usr/local/bin

# Crear wrapper que filtra mensajes de upsmon
sudo tee /usr/local/bin/wall > /dev/null << 'EOF'
#!/bin/bash
# Wrapper para wall que filtra mensajes de NUT/upsmon
# Lee stdin y solo ejecuta wall real si NO es un mensaje de NUT

MESSAGE=$(cat)

# Filtrar mensajes de NUT sobre suspend/hibernate
if echo "$MESSAGE" | grep -q "OS is entering sleep\|OS just finished sleep\|de-activating obsolete UPS"; then
    # Mensaje de NUT - no mostrar en terminales, solo logear
    logger -t nut-wall-filtered "$MESSAGE"
    exit 0
fi

# Otros mensajes sí se muestran
echo "$MESSAGE" | /usr/bin/wall.real
EOF

# Hacer el wrapper ejecutable
sudo chmod +x /usr/local/bin/wall

# Mover el wall original si no existe backup
if [ ! -f /usr/bin/wall.real ]; then
    sudo mv /usr/bin/wall /usr/bin/wall.real
    sudo ln -sf /usr/local/bin/wall /usr/bin/wall
    echo "✓ Wrapper instalado - mensajes de NUT sobre suspend/resume filtrados"
else
    echo "⚠️  wall.real ya existe - wrapper ya estaba instalado"
fi

echo ""
echo "Los mensajes de suspend/resume de NUT ahora van a syslog en lugar de broadcast"
echo "Ver con: journalctl -t nut-wall-filtered -f"
