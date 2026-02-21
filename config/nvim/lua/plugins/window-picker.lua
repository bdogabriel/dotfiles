return {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    version = "2.*",
    config = function()
        local wp = require("window-picker")
        wp.setup({
            hint = "floating-big-letter",
            show_prompt = false,
            filter_rules = {
                include_current_win = true,
                -- filter using buffer options
                bo = {
                    -- if the file type is one of following, the window will be ignored
                    buftype = { "terminal" },
                },
            },
        })
        vim.keymap.set("n", "<leader><space>", function()
            local win_id = wp.pick_window()
            if win_id then
                vim.api.nvim_set_current_win(win_id)
            end
        end, { desc = "Window: pick", noremap = true, silent = true })
        vim.keymap.set("n", "<localleader>w", function()
            local win_id = wp.pick_window()
            local is_last_window = #vim.api.nvim_tabpage_list_wins(0) == 1
            if win_id and not is_last_window then
                vim.api.nvim_win_close(win_id, false)
            end
        end, { desc = "Window: pick close", noremap = true, silent = true })
    end,
}
