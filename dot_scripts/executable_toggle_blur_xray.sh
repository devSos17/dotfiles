#!/bin/bash
# Con provider lua, `hyprctl keyword` no existe ("use eval") -> hl.config via eval.
# getoption -j devuelve {"bool": ...} para booleanos (antes {"int": ...}).

current=$(hyprctl getoption decoration:blur:xray -j | jq -r 'if .bool != null then (if .bool then 1 else 0 end) else (.int // 0) end')

if [ "$current" -eq 0 ]; then
    hyprctl eval 'hl.config({ decoration = { blur = { xray = true } } })'
    notify-send -t 2000 "Blur X-Ray" "Enabled: See windows behind"
else
    hyprctl eval 'hl.config({ decoration = { blur = { xray = false } } })'
    notify-send -t 2000 "Blur X-Ray" "Disabled: See wallpaper"
fi
