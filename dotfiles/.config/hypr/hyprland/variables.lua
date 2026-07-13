-- Shared variables, required by other modules.
-- Replaces hyprlang `$var` expansion (which does not exist in Lua).
-- Usage in other files:  local vars = require("hyprland.variables")

return {
    terminal         = "footclient",
    notes            = "obsidian",
    menu             = os.getenv("HOME") .. "/.config/wofi/wofi-toggle.sh",
    mainMod          = "SUPER",
    fileManager      = "nautilus --new-window",
    editor           = "subl",
    browser          = "helium-browser",
    launchScriptsDir = os.getenv("HOME") .. "/.local/share/launch-scripts",

    -- Animation / styling
    animSpeed = 1.5,
    opacity   = 0.85,
}
