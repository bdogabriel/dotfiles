return {
    "sindrets/diffview.nvim",
    config = function()
        local diffview = require("diffview")
        local actions = require("diffview.actions")
        local lib = require("diffview.lib")

        local function close_diffview()
            diffview.close()
        end

        diffview.setup({
            keymaps = {
                view = {
                    { "n", "q", close_diffview, { desc = "Close Diffview" } },
                },
                file_panel = {
                    { "n", "q", close_diffview, { desc = "Close Diffview" } },
                    { "n", "<cr>", actions.goto_file_edit, { desc = "Open the file in the editor" } },
                },
                file_history_panel = {
                    { "n", "q", close_diffview, { desc = "Close Diffview" } },
                    { "n", "<cr>", actions.goto_file_edit, { desc = "Open the file in the editor" } },
                },
            },
        })

        vim.keymap.set("n", "<leader>gg", function()
            for _, view in ipairs(lib.views) do
                if view.tabpage and vim.api.nvim_tabpage_is_valid(view.tabpage) then
                    vim.api.nvim_set_current_tabpage(view.tabpage)
                    return
                end
            end
            vim.cmd("DiffviewOpen")
        end, { desc = "Diffview", noremap = true, silent = true })

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
