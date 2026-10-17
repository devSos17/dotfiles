-- Zoom: class "zoom" en XWayland, "Zoom" en Wayland nativo (zoomus.conf xwayland=false)
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
    match = { class = "^([Zz]oom)$" },
    suppress_event = "activate activatefocus",
})

-- 2) Ventanas auxiliares de Zoom (toolbar al compartir pantalla, mini video
--    flotante, popups de notificacion): flotantes, sin robar focus al abrir (NO usar no_focus: las deja intocables), sin animacion.
--    Titulos conocidos de Zoom en Linux; el principal ("Reunión"/"Zoom
--    Workplace"/"Zoom Meeting") NO entra aca.
hl.window_rule({
    name = "zoom-helpers",
    match = { class = "^([Zz]oom)$", title = "^(zoom_linux_float_video_window|as_toolbar|annotate_toolbar|zoom_linux_float_message_reminder|Zoom|)$" },
    float = true,
    no_initial_focus = true,
    no_anim = true,
})

-- 3) Lapiz de anotacion (annotate_toolbar): ventana transparente que "flota"
--    sobre el video. Se deja tal cual en layout/focus (si se fuerza float o
--    no_focus las vuelve intocables), pero sin dim/blur/sombra para que no
--    oscurezca ni desenfoque el video (dim_inactive y blur son globales en ui.lua).
hl.window_rule({
    name = "zoom-annotate-no-fx",
    match = { class = "^([Zz]oom)$", title = "^(annotate_toolbar)$" },
    no_dim = true,
    no_blur = true,
    no_shadow = true,
    opacity = "1.0 override 1.0 override",
})
