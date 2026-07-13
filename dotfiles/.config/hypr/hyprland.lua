-- Hyprland Lua config entry point.
-- Since Hyprland 0.55, hyprlang (.conf) is deprecated in favor of Lua.
-- If this file exists it is loaded INSTEAD of hyprland.conf.
--
-- The config is split into modules under hyprland/ for readability.

-- Make this directory's modules requireable as `hyprland.<name>`,
-- i.e. <config>/hypr/hyprland/<name>.lua
local config_dir = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
package.path = config_dir .. "/hypr/?.lua;" .. package.path

-- Order matters (mirrors the old source order).
require("hyprland.variables") -- shared vars (also required by the modules below)
require("hyprland.env")
require("hyprland.general")
require("hyprland.rules")
require("hyprland.colors")
require("hyprland.keybinds")
require("hyprland.execs")
