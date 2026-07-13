-- Window & layer rules.
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- Rules are evaluated top to bottom; order matters (last match wins).

local vars    = require("hyprland.variables")
local opacity = tostring(vars.opacity) -- opacity rule values are strings

-- ######## Window rules ########
hl.window_rule({ match = { class = "" }, no_blur = true, float = true, opaque = true })

-- Disable transparency for popup menus and dropdowns
hl.window_rule({ match = { title = "menu" },     opaque = true, no_blur = true })
hl.window_rule({ match = { class = "menu" },     opaque = true, no_blur = true })
hl.window_rule({ match = { title = "dropdown" }, opaque = true, no_blur = true })
hl.window_rule({ match = { class = "dropdown" }, opaque = true, no_blur = true })

-- For more generic popup/menu matching
hl.window_rule({ match = { title = "popup" },        opaque = true, no_blur = true })
hl.window_rule({ match = { class = "popup" },        opaque = true, no_blur = true })
hl.window_rule({ match = { title = "" },             opaque = true, no_blur = true })
hl.window_rule({ match = { class = "" },             opaque = true, no_blur = true })
hl.window_rule({ match = { class = "virt-manager" }, opaque = true, no_blur = false })

-- Match common menu window types
hl.window_rule({ match = { class = ".*(menu).*" }, opaque = true, no_blur = true })
hl.window_rule({ match = { title = ".*(menu).*" }, opaque = true, no_blur = true })

-- For tooltips
hl.window_rule({ match = { class = "tooltip" }, opaque = true, no_blur = true })
hl.window_rule({ match = { title = "tooltip" }, opaque = true, no_blur = true })

-- For modals
-- NOTE: verify `modal` is a supported match field on your Hyprland version.
hl.window_rule({ match = { modal = true }, opaque = true, no_blur = true })

-- Disable blur for xwayland context menus
hl.window_rule({ match = { xwayland = true }, no_blur = true, opaque = true })

-- For images, videos and games (content 1 = photo, 2 = video)
hl.window_rule({ match = { content = "photo" }, no_blur = true, opaque = true })
hl.window_rule({ match = { content = "video" }, no_blur = true, opaque = true })

-- Floating
hl.window_rule({ match = { class = "blueberry\\.py" },              float = true })
hl.window_rule({ match = { class = "guifetch" },                   float = true })
hl.window_rule({ match = { class = "pavucontrol-qt" },             float = true })
hl.window_rule({ match = { class = "pavucontrol-qt" },             size = { 600, 300 } })
hl.window_rule({ match = { class = "pavucontrol-qt" },             center = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol-qt" }, float = true })
hl.window_rule({ match = { class = "nm-connection-editor" },       float = true })
hl.window_rule({ match = { class = "nm-connection-editor" },       size = { 600, 300 } })
hl.window_rule({ match = { class = "nm-connection-editor" },       center = true })
hl.window_rule({ match = { class = ".*plasmawindowed.*" },         float = true })
hl.window_rule({ match = { class = "kcm_.*" },                     float = true })
hl.window_rule({ match = { class = ".*bluedevilwizard" },          float = true })
hl.window_rule({ match = { title = ".*Welcome" },                  float = true })
hl.window_rule({ match = { title = "illogical-impulse Settings" }, float = true })
hl.window_rule({ match = { class = "org.freedesktop.impl.portal.desktop.kde" }, float = true })
hl.window_rule({ match = { class = "Zotero" },                     float = true })
hl.window_rule({ match = { class = "Zotero" },                     size = { 600, 300 } })

-- Picture-in-Picture
local pip = "[Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture.*"
hl.window_rule({ match = { title = pip }, float = true })
hl.window_rule({ match = { title = pip }, keep_aspect_ratio = true })
-- original: move 73% 72% (percentage of monitor)
hl.window_rule({ match = { title = pip }, move = { "monitor_w*0.73", "monitor_h*0.72" } })
-- hl.window_rule({ match = { title = pip }, size = { "monitor_w*0.25", "monitor_h*0.25" } })
hl.window_rule({ match = { title = pip }, float = true })
hl.window_rule({ match = { title = pip }, pin = true })

-- Dialog windows – float + center these windows.
hl.window_rule({ match = { title = "Open File.*" },      center = true, float = true })
hl.window_rule({ match = { title = "Open folder.*" },    center = true, float = true })
hl.window_rule({ match = { title = "Select a File.*" },  center = true, float = true })
hl.window_rule({ match = { title = "Select Folder.*" },  center = true, float = true })
hl.window_rule({ match = { title = "Choose wallpaper.*" }, center = true, float = true })
hl.window_rule({ match = { title = "Open Folder.*" },    center = true, float = true })
hl.window_rule({ match = { title = "Save As.*" },        center = true, float = true })
hl.window_rule({ match = { title = "Library.*" },        center = true, float = true })
hl.window_rule({ match = { title = "File Upload.*" },    center = true, float = true })
hl.window_rule({ match = { title = ".*(wants to save)" }, center = true, float = true })
hl.window_rule({ match = { title = ".*(wants to open)" }, center = true, float = true })

-- --- Tearing ---
hl.window_rule({ match = { title = ".*\\.exe" },    immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ match = { class = "steam_app.*" }, immediate = true })

-- No shadow for tiled windows (matches windows that are not floating).
hl.window_rule({ match = { float = false }, no_shadow = true })

-- ====================================
-- ============ MY RULES ==============
-- ====================================
hl.window_rule({ match = { class = "org.gnome.Nautilus" },     float = true })
hl.window_rule({ match = { class = "com.github.hluk.copyq" },  float = true })
hl.window_rule({ match = { class = "brave" },                  float = true })
hl.window_rule({ match = { class = "imv" },                    float = true })
hl.window_rule({ match = { class = "com.gabm.satty" },         min_size = { 1, 1 } })

-- ==== Floating windows ====
hl.window_rule({ match = { class = "org.kde.kdeconnect.app" },      float = true })
hl.window_rule({ match = { class = "org.kde.kdeconnect.sms" },      float = true })
hl.window_rule({ match = { title = "Steam Settings" },             float = true })
hl.window_rule({ match = { class = "org.gnome.Loupe" },            float = true })
hl.window_rule({ match = { class = "python3" },                    float = true })
hl.window_rule({ match = { class = "org.qbittorrent.qBittorrent" }, float = true })
hl.window_rule({ match = { class = "calibre-gui" },                float = true })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk" },     float = true })
hl.window_rule({ match = { class = "balena-etcher" },              float = true })
hl.window_rule({ match = { class = "unityhub" },                   float = true })
hl.window_rule({ match = { class = "rustdesk" },                   float = true })
hl.window_rule({ match = { class = "org.gnome.DiskUtility" },      float = true })
hl.window_rule({ match = { class = "virt-manager", title = "Virtual Machine Manager" }, float = true })
hl.window_rule({ match = { title = ".*DevTools.*" },              float = true })

-- sizes
hl.window_rule({ match = { title = ".*DevTools.*" },          size = { 900, 700 }, center = true })
-- hl.window_rule({ match = { class = "org.kde.kdeconnect.sms" }, size = { "45%", "45%" } })
-- hl.window_rule({ match = { class = "org.kde.kdeconnect.app" }, size = { "45%", "45%" } })
hl.window_rule({ match = { class = "org.gnome.Nautilus" },    size = { 800, 600 }, center = true })

-- ==== Opacity ====  ($opacity lives in variables.lua)
hl.window_rule({ match = { class = "ferdium" },              opacity = opacity })
hl.window_rule({ match = { class = "kitty" },                opacity = opacity })
hl.window_rule({ match = { class = "sublime_text" },         opacity = opacity })
hl.window_rule({ match = { class = "code-oss" },             opacity = opacity })
hl.window_rule({ match = { class = "brave-browser-nightly" }, opacity = opacity })
hl.window_rule({ match = { title = ".*" },                   opacity = opacity })

hl.window_rule({ match = { class = "obsidian" }, immediate = true })
hl.window_rule({ match = { class = "obsidian" }, workspace = "special:magic" })

hl.window_rule({ match = { title = ".*YouTube.*" }, opacity = "1" })
hl.window_rule({ match = { title = ".*Netflix.*" }, opacity = "1" })

-- per-window opacity - opaque
hl.window_rule({ match = { class = "obsidian" }, opaque = true })
hl.window_rule({ match = { class = "ferdium" },  opaque = true })

-- Float/center the Steam launcher
hl.window_rule({ match = { class = "steam", title = ".*Slay the Spire.*" }, float = true, center = true })

-- Fullscreen the actual game windows (note the spaces in class names)
hl.window_rule({ match = { class = "Modded Slay the Spire" }, fullscreen = true })
-- original also had `maximize on`; no direct Lua prop, using fullscreen.
hl.window_rule({ match = { title = "This War of Mine" },     fullscreen = true })
hl.window_rule({ match = { class = "Slay the Spire" },       fullscreen = true })
hl.window_rule({ match = { class = "Kodi" },                 fullscreen = true })

-- Layer rules
hl.layer_rule({ match = { namespace = "wofi" },    animation = "fade" })
hl.layer_rule({ match = { namespace = "overlay" }, no_anim = true })

-- to get rid of animation artefacts on floating windows
hl.window_rule({ match = { float = true }, opaque = true })
hl.window_rule({ match = { float = true }, no_blur = true })
hl.window_rule({ match = { float = true }, border_size = 0 })

-- autofocus
-- hl.window_rule({ match = { class = "brave-browser-nightly" }, focus_on_activate = true })
hl.window_rule({ match = { class = "sublime_text" }, focus_on_activate = true })
-- hl.window_rule({ match = { class = "Alacritty" }, no_anim = true })
hl.window_rule({ match = { class = "mpv" }, float = true, opaque = true, opacity = "1", no_blur = true })
