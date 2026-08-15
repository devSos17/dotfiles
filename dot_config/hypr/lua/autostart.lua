-- Autostart
-- Origen: dot_config/hypr/hyprland.conf (lineas exec-once)
--
-- hl.exec_cmd() spawnea un proceso asincrono, no hace falta "& disown".
-- Confirmado en la wiki oficial (Configuring/Basics/Autostart).

hl.on("hyprland.start", function()
    hl.exec_cmd("~/.config/hypr/scripts/autostart.sh")
    hl.exec_cmd("~/.config/hypr/scripts/import_gtk.sh")
end)
