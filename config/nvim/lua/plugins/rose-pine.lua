return {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
        variant = "moon",
        palette = {
            moon = {
                base = "#000000",
                surface = "#000000",
                overlay = "#26233a",
            },
        },
        highlight_groups = {
            Visual = { fg = "none", bg = "highlight_med", inherit = false },
        },
    },
}
