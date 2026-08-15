-- Hyprland Lua config entry point (0.55+/0.56+ format)
--
-- Migrado desde dot_config/hypr/*.conf (hyprlang), que sera removido en
-- Hyprland 0.57 (ver notificacion "You are using the .conf config format,
-- support for which will be removed in Hyprland 0.57.").
--
-- PATRON: replica el enfoque modular de ~/.config/nvim/init.lua:
--   nvim:  init.lua -> require 'options' / 'keybinds' / 'filetype' (modulos
--          planos en lua/), luego lazy.nvim auto-importa cada spec bajo
--          lua/plugins/*.lua via { import = 'plugins' }.
--   aqui:  hyprland.lua -> require de modulos "core" planos en lua/, y luego
--          un require con wildcard que auto-carga cada archivo bajo
--          lua/rules/*.lua (equivalente nativo de Hyprland al "import" de
--          lazy.nvim para plugins/reglas modulares).
--
-- Cada modulo requerido es "side-effect based" (llama hl.config/hl.bind/etc
-- directamente), igual que lua/keybinds.lua en nvim -- no retorna tablas.

require("lua/env")
require("lua/general")
require("lua/ui")
require("lua/devices")
require("lua/monitor")
require("lua/workspace")
require("lua/keybinds")
require("lua/autostart")

-- Window rules: un archivo por app/grupo (como lua/plugins/*.lua en nvim),
-- auto-cargado con wildcard require en vez de import manual por archivo.
--
-- ADVERTENCIA: el orden de evaluacion de require("./lua/rules/*") NO esta
-- garantizado (a diferencia de un require explicito linea por linea). Las
-- window rules se evaluan top-to-bottom y el orden SI importa cuando el
-- ultimo match que aplica gana. Si dos reglas con `match` solapado dependen
-- de cual se evalua primero (ej. una regla general y una mas especifica para
-- la misma clase de ventana), NO las separes en archivos distintos dentro de
-- rules/ -- ponelas juntas, en orden, en un mismo archivo.
require("./lua/rules/*")
