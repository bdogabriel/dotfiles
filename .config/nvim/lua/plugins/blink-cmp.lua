return {
    "saghen/blink.cmp",
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = "super-tab",
        },
        cmdline = {
            completion = {
                menu = {
                    auto_show = true,
                },
            },
            keymap = {
                preset = "inherit",
            },
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            ghost_text = {
                enabled = false,
            },
            documentation = {
                auto_show = true,
                window = {
                    border = "rounded",
                    winblend = 25,
                    winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
                },
            },
            menu = {
                border = "rounded",
                winblend = 25,
            },
        },
        signature = {
            enabled = true,
        },
        sources = {
            default = { "lsp", "path", "buffer" },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
}
