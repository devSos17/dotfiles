-- Brave: fix de crashes al cambiar de monitor
-- Origen: dot_config/hypr/conf/rules.conf
--
-- La class real es 'brave-browser' (minuscula), verificado con `hyprctl
-- clients`. Antes decia (Brave-browser) sin anclas -> match case-sensitive
-- fallido, la regla nunca aplicaba (fix en commit ec1cbb3).

hl.window_rule({
    name = "brave-fix-monitor-switch",
    match = { class = "^(brave-browser)$" },
    immediate = true,
})
