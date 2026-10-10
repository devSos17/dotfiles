-- OrcaSlicer (class "orca-slicer")
-- Evita que robe el focus por peticion propia (activate requests).
-- Click / keybind siguen funcionando normal.
hl.window_rule({
    name = "orca-slicer-no-focus-steal",
    match = { class = "^(orca-slicer)$" },
    suppress_event = "activate activatefocus",
})
