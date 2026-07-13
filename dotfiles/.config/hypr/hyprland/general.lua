-- Monitors, workspaces, input, look & feel, animations, misc.

----------------
-- MONITORS ----
----------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0",    scale = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60", position = "1920x0", scale = 1 })

------------------
-- WORKSPACES ----
------------------
-- Assign workspaces to specific monitors
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-2", default = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-2" })

-------------
-- INPUT ----
-------------
hl.config({
    input = {
        kb_layout  = "pl",
        kb_options = "caps:super,altwin:hyper_win", -- Caps Lock -> another Super key
        numlock_by_default = false,

        -- Faster keyboard repeat
        repeat_rate  = 60,
        repeat_delay = 150,

        follow_mouse = 1,
        accel_profile = "flat",
        sensitivity   = 1, -- -1.0 - 1.0, 0 means no modification.
        off_window_axis_events = 2,

        touchpad = {
            natural_scroll        = true,
            disable_while_typing  = true,
            clickfinger_behavior  = true,
            scroll_factor         = 0.5,
        },
    },
})

--------------------
-- LOOK AND FEEL ---
--------------------
hl.config({
    general = {
        -- layout = "scrolling",
        gaps_in         = 5,
        -- hyprlang `gaps_out = 5,10,10,10` is top,right,bottom,left
        gaps_out        = { top = 5, right = 10, bottom = 10, left = 10 },
        gaps_workspaces = 10,

        border_size      = 1,
        resize_on_border = true,

        no_focus_fallback = true,

        allow_tearing = true, -- allows the `immediate` window rule to work

        snap = {
            enabled = true,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = false,
        -- precise_mouse_move = true,
    },

    decoration = {
        rounding = 4,

        blur = {
            enabled                = true,
            xray                   = true,
            special                = false,
            new_optimizations      = true,
            size                   = 14,
            passes                 = 3,
            brightness             = 1,
            noise                  = 0.01,
            contrast               = 1,
            popups                 = false,
            popups_ignorealpha     = 0.6,
            input_methods          = true,
            input_methods_ignorealpha = 0.8,
        },

        shadow = {
            enabled      = true,
            -- ignore_window = true,
            range        = 30,
            offset       = { 0, 2 },
            render_power = 4,
            -- rgba(00000010) -> ARGB 0x10000000
            color        = 0x10000000,
        },

        -- Dim
        dim_inactive = true,
        dim_strength = 0.1,
        dim_special  = 0.07,
    },

    animations = {
        enabled = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        -- vfr = 1,
        vrr = 1,
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
        animate_manual_resizes   = false,
        animate_mouse_windowdragging = false,
        enable_swallow           = false,
        swallow_regex            = "(foot|kitty|allacritty|Alacritty)",
        -- new_window_takes_over_fullscreen = 2,
        allow_session_lock_restore = true,
        session_lock_xray          = true,
        -- initial_workspace_tracking = false,
        -- focus_on_activate = true,
    },

    binds = {
        scroll_event_delay = 0,
        hide_special_on_workspace_change = true,
    },

    cursor = {
        zoom_factor       = 1,
        zoom_rigid        = false,
        inactive_timeout  = 2,
        hide_on_key_press = true,
    },

    -- plugin = {
    --     hyprscrolling = {
    --         column_width = 0.8,
    --         fullscreen_on_one_column = false,
    --     },
    -- },
})

------------------
-- ANIMATIONS ----
------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
local vars = require("hyprland.variables")
local animSpeed = vars.animSpeed

hl.curve("snappy", { type = "bezier", points = { {0.17, 0.9}, {0.2, 1.0} } })
hl.curve("slide",  { type = "bezier", points = { {0.16, 1},   {0.3, 1}   } })

hl.animation({ leaf = "windows",     enabled = true, speed = animSpeed, bezier = "snappy" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = animSpeed, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = animSpeed, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = animSpeed, bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = animSpeed, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4.5,       bezier = "slide", style = "slidefade 15%" })
hl.animation({ leaf = "layers",      enabled = true, speed = animSpeed, bezier = "snappy" })
