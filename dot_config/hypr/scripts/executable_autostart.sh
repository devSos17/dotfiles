#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@ &
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
# `--daemon` ya no existe en ulauncher 5.15+ (falla con "no such option" y no
# arranca). El equivalente actual es --hide-window.
run ulauncher --hide-window


run sleep 2 && after

