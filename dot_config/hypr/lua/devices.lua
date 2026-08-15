-- Input / dispositivos
-- Origen: dot_config/hypr/conf/devices.conf

hl.config({
    input = {
        kb_layout = "latam",
        -- kb_options = "caps:swapescape", -- resuelto con keyd
        -- kb_variant = "",
        -- kb_model = "",
        -- kb_rules = "",
        repeat_rate = 50,
        repeat_delay = 250,

        follow_mouse = 1,

        touchpad = {
            natural_scroll = false,
            drag_lock = true,
        },

        sensitivity = 0.0, -- -1.0 a 1.0, 0 significa sin modificacion
        -- force_no_accel = true, -- no tan bueno...
    },
})

-- Config por dispositivo
-- Ejemplo generico: device:epic-mouse-v1 { sensitivity = -0.5 }
hl.device({
    name = "wacom-bamboopt-2fg-4x5-pen",
    output = "eDP-1",
    -- NOTA: solo un output por dispositivo es soportado; un segundo valor sobreescribe al primero
})

hl.device({
    name = "elan1201:00-04f3:3098-touchpad",
    sensitivity = 0.1,
})
