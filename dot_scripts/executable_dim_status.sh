#!/bin/bash

STATEFILE="/tmp/hypr-dim-disabled"

if [ -f "$STATEFILE" ]; then
    echo '{"text":"󰃠","tooltip":"Dim: Disabled","class":"dim-off"}'
else
    echo '{"text":"󰃞","tooltip":"Dim: Enabled","class":"dim-on"}'
fi
