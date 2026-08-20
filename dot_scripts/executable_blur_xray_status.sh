#!/bin/bash
# Con el config provider lua, `getoption -j` devuelve {"bool": ...} para
# opciones booleanas (antes {"int": 0|1}). Se aceptan ambas formas.

current=$(hyprctl getoption decoration:blur:xray -j | jq -r 'if .bool != null then (if .bool then 1 else 0 end) else (.int // 0) end')

if [ "$current" -eq 0 ]; then
    echo '{"text":"⨯","tooltip":"Blur: Wallpaper (xray OFF)","class":"xray-off"}'
else
    echo '{"text":"X","tooltip":"Blur: Windows behind (xray ON)","class":"xray-on"}'
fi
