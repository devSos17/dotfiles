#!/bin/bash
# Con provider lua, `hyprctl keyword` no existe ("use eval") -> hl.config via eval.

STATEFILE="/tmp/hypr-dim-disabled"

if [ -f "$STATEFILE" ]; then
    hyprctl eval 'hl.config({ decoration = { dim_inactive = true } })'
    rm "$STATEFILE"
    notify-send -t 2000 "Dim Inactive" "Enabled"
else
    hyprctl eval 'hl.config({ decoration = { dim_inactive = false } })'
    touch "$STATEFILE"
    notify-send -t 2000 "Dim Inactive" "Disabled"
fi
