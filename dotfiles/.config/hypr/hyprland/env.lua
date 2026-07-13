-- Environment variables
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- ######### Input method ##########
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")
hl.env("INPUT_METHOD", "fcitx")

-- XDG and GNOME compatibility
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("GNOME_DESKTOP_SESSION_ID", "")

-- ############ Wayland #############
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- ############ Themes #############
hl.env("QT_QUICK_CONTROLS_STYLE", "org.kde.desktop")
-- hl.env("GTK_THEME", "Adwaita:dark")
hl.env("GTK_THEME", "adw-gtk3-dark")

-- Cursor
hl.env("HYPRCURSOR_THEME", "HyprBibataModernClassicSVG")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- go and PATH
-- NOTE: Lua's hl.env does NOT expand $PATH (hyprlang did). We must expand it
-- ourselves, otherwise PATH becomes the literal string "$PATH:..." and no
-- spawned program (kitty, subl, etc.) can be found.
hl.env("GOPATH", "/usr/local/go")
local go_bin   = "/usr/local/go/bin"
local cur_path = os.getenv("PATH") or ""
-- Self-heal: if a previous (broken) load left the literal "$PATH" in place, or
-- PATH is empty, fall back to sane defaults so a plain `hyprctl reload` recovers.
if cur_path == "" or cur_path:find("$PATH", 1, true) then
    cur_path = "/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:"
        .. (os.getenv("HOME") or "") .. "/.local/bin"
end
if not cur_path:find(go_bin, 1, true) then -- avoid duplicate on reload
    cur_path = cur_path .. ":" .. go_bin
end
hl.env("PATH", cur_path)

hl.env("BROWSER", "helium-browser")

-- ######## Wayland #########
-- Tearing
-- hl.env("WLR_DRM_NO_ATOMIC", "1")
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")
