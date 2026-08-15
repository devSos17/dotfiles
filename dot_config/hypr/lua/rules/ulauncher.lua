-- Ulauncher: desactivar blur/xray para borde transparente
-- Origen: dot_config/hypr/conf/rules.conf

hl.window_rule({
    name = "ulauncher-appearance",
    match = { class = "^(ulauncher)$" },
    no_blur = true,
    no_shadow = true,
    xray = false,
    border_size = 0,
    float = true,
})
