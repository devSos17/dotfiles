#!/bin/bash

current=$(hyprctl getoption decoration:blur:xray -j | jq -r '.int')

if [ "$current" -eq 0 ]; then
    echo '{"text":"⨯","tooltip":"Blur: Wallpaper (xray OFF)","class":"xray-off"}'
else
    echo '{"text":"X","tooltip":"Blur: Windows behind (xray ON)","class":"xray-on"}'
fi
