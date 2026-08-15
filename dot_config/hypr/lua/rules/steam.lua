-- Steam
-- Origen: dot_config/hypr/conf/rules.conf

-- Ventanas normales de Steam - forzar tile
hl.window_rule({
    name = "steam-normal-tile",
    match = { class = "^(steam)$", title = "^(Steam)$" },
    tile = true,
})

-- Steam Big Picture / Game Mode - fullscreen
hl.window_rule({
    name = "steam-bigpicture-fullscreen-1",
    match = { class = "^(steam)$", title = "^(.*Big Picture.*)$" },
    fullscreen = true,
})

hl.window_rule({
    name = "steam-bigpicture-fullscreen-2",
    match = { class = "^(steam)$", title = "^(Steam Big Picture Mode)$" },
    fullscreen = true,
})

hl.window_rule({
    name = "steam-webhelper-fullscreen",
    match = { class = "^(steamwebhelper)$" },
    fullscreen = true,
})

-- Notificaciones de Steam (toasts) - workspace especial silencioso
hl.window_rule({
    name = "steam-notification-toasts",
    match = { class = "^(steam)$", title = "^(notificationtoasts.*)$" },
    workspace = "special:steam silent",
})

-- Notificaciones de Steam (friends list, screenshot uploader, news) - float
hl.window_rule({
    name = "steam-notifications-float",
    match = { class = "^(steam)$", title = "^(Friends List|Screenshot Uploader|Steam - News)$" },
    float = true,
})
