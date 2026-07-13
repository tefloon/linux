-- Keybindings
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local vars    = require("hyprland.variables")
local mainMod = vars.mainMod

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(vars.editor))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(vars.browser .. " --ozone-platform=wayland"))

-- --- Dictation ---
hl.bind("MOD3 + Z", hl.dsp.exec_cmd("~/.local/bin/dictate en"))
hl.bind("MOD3 + X", hl.dsp.exec_cmd("~/.local/bin/dictate pl"))

-- --- Window Management ---
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + D", hl.dsp.layout("togglesplit"))

-- --- Move Focus ---
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- --- Move Focus (vim) ---
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))

-- --- Move Active Window ---
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- --- Workspaces: switch (mainMod + N) and move window (mainMod + SHIFT + N) ---
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }))
end

-- --- Special Workspace (Scratchpad) ---
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- --- Mouse and Scrolling ---
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- --- Screenshots (Wayland Native) ---
hl.bind(mainMod .. " + F11", hl.dsp.exec_cmd("~/.local/bin/screenshot-with-window"))
hl.bind(mainMod .. " + F12", hl.dsp.exec_cmd("~/.local/bin/screenshot"))
hl.bind(mainMod .. " + F10", hl.dsp.exec_cmd("~/.local/bin/ocr"))
hl.bind(mainMod .. " + F9",  hl.dsp.exec_cmd("~/.local/bin/picker"))

-- --- Clipboard history ---
hl.bind("CONTROL + grave", hl.dsp.exec_cmd(vars.launchScriptsDir .. "/wofi-clip-history.sh"))

-- --- Launch Claude ---
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(vars.launchScriptsDir .. "/launch-claude.sh"))

-- --- Multimedia Keys ---
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),                          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),                          { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- Notify with the active window's class AND title.
hl.bind("MOD3 + I", hl.dsp.exec_cmd([[notify-send "Window Info" "$(hyprctl activewindow | awk '/class:/ {print "Class: " $2} /title:/ { $1=""; print "Title: " substr($0, 2) }')" | cb]]))
-- Copy the active window's class.
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd([[$(hyprctl activewindow | awk '/class:/ {print $2}' | wl-copy)]]))

hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(vars.launchScriptsDir .. "/wofi-search-internet.sh"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(vars.launchScriptsDir .. "/wofi-toggle.sh"))

-- Column moves (scrolling layout)
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma",  hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("movewindowto r"))
hl.bind(mainMod .. " + SHIFT + comma",  hl.dsp.layout("movewindowto l"))
