-- Colors: border gradients, background, and the pinned-window border rule.

hl.config({
    general = {
        col = {
            active_border   = "rgba(90909aAA)",
            inactive_border = "rgba(46464fAA)",
        },
    },

    misc = {
        -- rgba(121318FF) -> ARGB 0xFF121318
        background_color = 0xFF121318,
    },
})

-- windowrulev = bordercolor rgba(bac3ffAA) rgba(bac3ff77), pinned:1
hl.window_rule({
    name         = "pinned-border",
    match        = { pin = true },
    border_color = "rgba(bac3ffAA) rgba(bac3ff77)",
})
