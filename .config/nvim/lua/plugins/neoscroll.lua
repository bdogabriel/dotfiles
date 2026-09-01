return {
    "karb94/neoscroll.nvim",
    opts = {
        respect_scrolloff = true,
    },
    config = function(_, opts)
        require("neoscroll").setup(opts)
    end,
}
