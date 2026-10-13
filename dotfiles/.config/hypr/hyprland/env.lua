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

hl.env("BROWSER", "helium-browser")

-- ######## Wayland #########
-- Tearing
-- hl.env("WLR_DRM_NO_ATOMIC", "1")
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")
