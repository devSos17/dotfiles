#!/bin/bash

current=$(hyprctl getoption decoration:blur:xray -j | jq -r '.int')

if [ "$current" -eq 0 ]; then
    hyprctl keyword decoration:blur:xray true
    notify-send -t 2000 "Blur X-Ray" "Enabled: See windows behind"
else
    hyprctl keyword decoration:blur:xray false
    notify-send -t 2000 "Blur X-Ray" "Disabled: See wallpaper"
fi
