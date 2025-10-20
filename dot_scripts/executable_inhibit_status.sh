#!/bin/bash

PIDFILE="/tmp/systemd-inhibit.pid"

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    echo '{"text":"☕","tooltip":"Idle: INHIBITED (awake)","class":"inhibited"}'
else
    [ -f "$PIDFILE" ] && rm "$PIDFILE"
    echo '{"text":"󰒲","tooltip":"Idle: Enabled (can sleep)","class":"idle"}'
fi
