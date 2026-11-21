-- Autostart
-- Origen: dot_config/hypr/hyprland.conf (lineas exec-once)
--
-- hl.exec_cmd() spawnea un proceso asincrono, no hace falta "& disown".
-- Confirmado en la wiki oficial (Configuring/Basics/Autostart).

hl.on("hyprland.start", function()
    -- Importar el entorno de sesion a systemd --user y dbus ANTES de lanzar apps.
    -- Sin XDG_SESSION_TYPE=wayland, Brave/Chromium/Zoom (hijos de systemd --user)
    -- usan el capturador X11 al compartir pantalla -> pantalla negra, y nunca
    -- llaman a xdg-desktop-portal-hyprland.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP DISPLAY")
    hl.exec_cmd("~/.config/hypr/scripts/autostart.sh")
    hl.exec_cmd("~/.config/hypr/scripts/import_gtk.sh")
    -- Luces RGB + monitores al arrancar (tras un suspend lo hace lights-resume.service).
    hl.exec_cmd("~/.scripts/lights on")
end)
