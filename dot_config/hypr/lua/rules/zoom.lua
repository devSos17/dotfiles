-- Zoom (XWayland, class "zoom")
--
-- Problema: Zoom roba el focus (pide activacion al abrir popups/notificaciones
-- y al cambiar estado de la reunion) y crea una ventanita auxiliar con icono
-- que hace jitter (aparece/desaparece/se mueve).
--
-- Estas reglas viven juntas en un solo archivo a proposito (ver advertencia de
-- orden en hyprland.lua).

-- 1) Ninguna ventana de Zoom puede robar el focus por peticion propia.
--    Click / keybind siguen funcionando normal (solo bloquea activate requests).
hl.window_rule({
    name = "zoom-no-focus-steal",
    match = { class = "^(zoom)$" },
    suppress_event = "activate activatefocus",
})

-- 2) Ventanas auxiliares de Zoom (toolbar al compartir pantalla, mini video
--    flotante, popups de notificacion): flotantes, sin focus, sin animacion.
--    Titulos conocidos de Zoom en Linux; el principal ("Reunión"/"Zoom
--    Workplace"/"Zoom Meeting") NO entra aca.
hl.window_rule({
    name = "zoom-helpers",
    match = { class = "^(zoom)$", title = "^(zoom_linux_float_video_window|as_toolbar|zoom_linux_float_message_reminder|Zoom|)$" },
    float = true,
    no_initial_focus = true,
    no_focus = true,
    no_anim = true,
})
