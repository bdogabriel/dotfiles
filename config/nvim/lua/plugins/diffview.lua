return {
    "sindrets/diffview.nvim",
    config = function()
        vim.keymap.set("n", "<leader>vo", "<CMD>DiffviewOpen<CR>", { desc = "Open", noremap = true, silent = true })
        vim.keymap.set(
            "n",
            "<leader>vH",
            "<CMD>DiffviewFileHistory<CR>",
            { desc = "File history (all)", noremap = true, silent = true }
        )
        vim.keymap.set(
            "n",
            "<leader>vh",
            "<CMD>DiffviewFileHistory %<CR>",
            { desc = "File history (current)", noremap = true, silent = true }
        )
        vim.keymap.set("n", "<leader>vc", "<CMD>DiffviewClose<CR>", { desc = "Close", noremap = true, silent = true })
        vim.keymap.set(
            "n",
            "<leader>vt",
            "<CMD>DiffviewToggleFiles<CR>",
            { desc = "Toggle File panel", noremap = true, silent = true }
        )
        vim.keymap.set(
            "n",
            "<leader>vr",
            "<CMD>DiffviewRefresh<CR>",
            { desc = "Refresh", noremap = true, silent = true }
        )
    end,
}
