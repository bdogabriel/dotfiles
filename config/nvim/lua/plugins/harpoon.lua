return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon").setup()
        local extensions = require("harpoon.extensions")

        harpoon:extend(extensions.builtins.navigate_with_number())
        harpoon:extend({
            UI_CREATE = function(cx)
                for line_number, file in pairs(cx.contents) do
                    if string.find(cx.current_file, file, 1, true) then
                        -- highlight the harpoon menu line that corresponds to the current buffer
                        vim.api.nvim_buf_add_highlight(cx.bufnr, -1, "SpecialKey", line_number - 1, 0, -1)
                        -- set the position of the cursor in the harpoon menu to the start of the current buffer line
                        vim.api.nvim_win_set_cursor(cx.win_id, { line_number, 0 })
                    end
                end
            end,
        })
        harpoon:extend({
            UI_CREATE = function(cx)
                vim.keymap.set("n", "<C-v>", function()
                    harpoon.ui:select_menu_item({ vsplit = true })
                end, { buffer = cx.bufnr })

                vim.keymap.set("n", "<C-s>", function()
                    harpoon.ui:select_menu_item({ split = true })
                end, { buffer = cx.bufnr })
            end,
        })

        vim.keymap.set("n", "<leader>hh", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Toggle quick menu" })

        vim.keymap.set("n", "<leader>ha", function()
            harpoon:list():add()
        end, { desc = "Add file" })

        for i = 1, 9 do
            vim.keymap.set("n", "<leader>" .. i, function()
                harpoon:list():select(i)
            end, { desc = "Harpoon: select " .. i })
        end

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "[b", function()
            harpoon:list():prev()
        end)
        vim.keymap.set("n", "]b", function()
            harpoon:list():next()
        end)
    end,
}
