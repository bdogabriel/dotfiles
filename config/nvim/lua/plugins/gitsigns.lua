return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require("gitsigns").setup({
            current_line_blame = true,
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]h", function()
                    gitsigns.nav_hunk("next")
                end)

                map("n", "[h", function()
                    gitsigns.nav_hunk("prev")
                end)

                map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
                map("v", "<leader>gs", function()
                    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end)
                map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })
                map("v", "<leader>gr", function()
                    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end)

                map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer" })
                map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset buffer" })
                map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
                map("n", "<leader>gi", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })

                map("n", "<leader>gb", function()
                    gitsigns.blame_line({ full = true })
                end, { desc = "Blame line" })

                -- map("n", "<leader>gQ", function()
                -- 	gitsigns.setqflist("all")
                -- end, { desc = "Set quick fix list all" })
                -- map("n", "<leader>gq", gitsigns.setqflist, { desc = "Set quick fix list" })

                -- Toggles
                map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, { desc = "Current line blame" })
                map("n", "<leader>gtd", gitsigns.toggle_deleted, { desc = "Deleted" })
                map("n", "<leader>gtw", gitsigns.toggle_word_diff, { desc = "Word diff" })
            end,
            preview_config = {
                border = "none",
            },
        })
    end,
}
