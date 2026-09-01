return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    opts = {
        search = {
            command = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--no-ignore-vcs",
                "--hidden",
            },
        },
    },
    keys = {
        {
            "<leader>st",
            function()
                Snacks.picker.todo_comments({ hidden = true })
            end,
            desc = "Todo",
        },
    },
}
