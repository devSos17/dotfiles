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
        -- DPMS wake lo maneja hypridle
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
