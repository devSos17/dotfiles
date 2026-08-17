#!/usr/bin/env bash

function run {
  # Se mantiene `pgrep -f` (match contra la cmdline completa) A PROPOSITO:
  # udiskie y solaar corren como `/usr/bin/python /usr/bin/<x>`, asi que su
  # comm es "python", y polkit-kde-authentication-agent-1 excede los 15 chars
  # que comm permite. Con `pgrep -x` ninguno de los tres matchearia nunca y se
  # relanzarian en cada arranque.
  # Cambios vs. la version previa: "$1" y "$@" citados, y pgrep silenciado
  # (imprimia los PIDs y ensuciaba el log de Hyprland).
  if ! pgrep -f "$1" >/dev/null 2>&1; then
    "$@" &
  fi
}
# after
function after {
    nextcloud &
    # run mailspring --background --password-store="gnome-libsecret"
    # run morgen
}

# SYSTEM
run /usr/lib/polkit-kde-authentication-agent-1 #Polkit auth
run hypridle
# run play-with-mpv
run waybar #Barra
run swaync #Notificaciones
run awww-daemon #Wallpapers
run kanshi #auto monitors
# TRAY
run udiskie -t
run solaar -w hide
# ulauncher 5.15 elimino `--daemon`; el reemplazo es `--hide-window`.
# Con el flag viejo el binario abortaba al instante ("no such option") y por eso
# ulauncher nunca arrancaba solo. Diagnosticado 2026-08-16.
run ulauncher --hide-window


run sleep 2 && after

