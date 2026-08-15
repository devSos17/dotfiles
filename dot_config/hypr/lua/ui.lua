-- UI: gaps, borders, decoracion, animaciones y layout
-- Origen: dot_config/hypr/conf/ui.conf
--
-- El drift original entre source y target sobre `dwindle {}` ya no existe:
-- el commit 97ac2ee ("hypr: brillo por %, quitar dwindle:pseudotile...")
-- resolvio la fuente para que coincida con el estado real, asi que esta nota
-- ya no aplica y quedaba confusa. Se deja el historial en git, no aqui.

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 1,

        col = {
            active_border = { colors = { "rgba(5de827ee)", "rgba(000000ee)" }, angle = 30 },
            inactive_border = "rgba(000000ee)",
        },

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,
        inactive_opacity = 0.97,

        shadow = {
            enabled = false,
            range = 8,
            render_power = 2,
            color = "rgba(1a1a1aee)",
        },

        dim_inactive = true,
        dim_strength = 0.25,
        dim_special = 0.0,

        blur = {
            enabled = true,
            size = 1,
            passes = 1,
            xray = false,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        -- `pseudotile` fue eliminado en Hyprland 0.56.2 (no renombrado: no
        -- existe ninguna opcion dwindle:*pseudo*). Tenerlo aca rompia el
        -- parseo entero del config (Error Overlay al arrancar) en 0.56.2+.
        -- Pseudo sigue disponible como dispatcher (hl.dsp.window.pseudo()).
        preserve_split = true,
    },
})

-- Beziers / curvas
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("easeInOutBack", { type = "bezier", points = { { 0.68, -0.6 }, { 0.32, 1.6 } } })

-- Animaciones
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
-- "borderangle" y "specialWorkspace" verificados EN VIVO contra una instancia
-- Hyprland anidada real (hyprctl animations): ambos leaves existen tal cual
-- y quedan seteados con los valores de abajo (overridden: 1, mismo bezier/
-- speed/style). TODOs cerrados, ya no son leaves inventados.
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "easeInOutBack", style = "slidefadevert 20%" })
