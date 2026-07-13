-- Autostart / exec.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- exec-once  -> hl.on("hyprland.start", ...)   (run once at launch)
-- exec       -> top-level hl.exec_cmd(...)     (run on every config load/reload)

local vars = require("hyprland.variables")

-- ===== Run on every config load (was `exec`) =====
hl.exec_cmd([[gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"]]) -- GTK3 apps
hl.exec_cmd([[gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"]]) -- GTK4 apps

-- ===== Run once at launch (was `exec-once`) =====
hl.on("hyprland.start", function()
    -- Bar, wallpaper
    -- hl.exec_cmd("~/.config/hypr/hyprland/scripts/start-geoclue-agent.sh")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("foot --server")

    -- Input method
    -- hl.exec_cmd("fcitx5")

    -- Core components (authentication, lock screen, notification daemon)
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    -- hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    -- hl.exec_cmd("dbus-update-activation-environment --all")

    -- Audio
    hl.exec_cmd("easyeffects --gapplication-service")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

    -- Top bar and tray
    hl.exec_cmd("waybar -c $HOME/.config/waybar/config.jsonc")
    hl.exec_cmd("waybar -c $HOME/.config/waybar/config_L.jsonc")
    -- hl.exec_cmd("waybar -c $HOME/.config/waybar/config_R.jsonc")

    -- ========== MY EXECS =========
    -- hl.exec_cmd("kdeconnectd")
    -- hl.exec_cmd("kdeconnect-indicator")

    -- Workspace-assigned launches (was `[workspace N silent] app`).
    -- NOTE: if these rules aren't honored, wrap as
    --       hl.dispatch(hl.dsp.exec_cmd(cmd, { workspace = "..." }))
    hl.exec_cmd("ferdium --ozone-platform=x11 %U", { workspace = "2 silent" })
    hl.exec_cmd(vars.terminal, { workspace = "6 silent" })
    hl.exec_cmd("obsidian", { workspace = "special:magic silent" })
end)
