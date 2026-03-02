#!/bin/bash

STATEFILE="/tmp/hypr-dim-disabled"

if [ -f "$STATEFILE" ]; then
    hyprctl keyword decoration:dim_inactive true
    rm "$STATEFILE"
    notify-send -t 2000 "Dim Inactive" "Enabled"
else
    hyprctl keyword decoration:dim_inactive false
    touch "$STATEFILE"
    notify-send -t 2000 "Dim Inactive" "Disabled"
fi
