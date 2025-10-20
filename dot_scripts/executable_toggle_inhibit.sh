#!/bin/bash

PIDFILE="/tmp/systemd-inhibit.pid"

if [ -f "$PIDFILE" ]; then
    kill $(cat "$PIDFILE") 2>/dev/null
    rm "$PIDFILE"
    notify-send -t 2000 "Idle Inhibit" "Disabled - System can sleep"
    echo '{"text":"󰒲","tooltip":"Idle: Enabled (can sleep)","class":"idle"}'
else
    systemd-inhibit --what=idle --who="Waybar" --why="User inhibited" sleep infinity &
    echo $! > "$PIDFILE"
    notify-send -t 2000 "Idle Inhibit" "Enabled - System stays awake"
    echo '{"text":"☕","tooltip":"Idle: INHIBITED (awake)","class":"inhibited"}'
fi
