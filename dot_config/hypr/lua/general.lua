-- General: comportamiento del compositor (no visual)
-- Origen: dot_config/hypr/conf/general.conf

hl.config({
    general = {
        allow_tearing = true,

        snap = {
            enabled = true,
            window_gap = 10,
        },
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        focus_on_activate = true,
        -- DPMS: hypridle apaga por idle / tras suspend; cualquier tecla vuelve a prender
        -- (necesario para ~/.scripts/lights off desde ssh).
        key_press_enables_dpms = true,
    },

    cursor = {
        hide_on_key_press = true,
        inactive_timeout = 5,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    debug = {
        disable_logs = false,
        enable_stdout_logs = false,
    },
})
