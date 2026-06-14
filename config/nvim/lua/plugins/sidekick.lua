return {
    "folke/sidekick.nvim",
    dependencies = {
        "folke/snacks.nvim",
    },
    opts = {
        cli = {
            mux = {
                backend = "tmux",
                enabled = true,
            },
            win = {
                split = {
                    width = 0.5,
                },
            },
            tools = {
                claude = { cmd = { "claude" } },
                opencode = { cmd = { "opencode" } },
            },
        },
        nes = {
            enabled = false,
        },
    },

    config = function(_, opts)
        require("sidekick").setup(opts)

        vim.api.nvim_create_autocmd("QuitPre", {
            desc = "Close sidekick chat on exit",
            callback = function()
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[buf].filetype == "sidekick_terminal" then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end
            end,
        })

        local map = vim.keymap.set

        map("n", "<leader>ac", function()
            require("sidekick.cli").toggle({ name = "claude", focus = true })
        end, { desc = "Toggle Claude Code CLI", noremap = true, silent = true })

        map("n", "<leader>ao", function()
            require("sidekick.cli").toggle({ name = "opencode", focus = true })
        end, { desc = "Toggle OpenCode CLI", noremap = true, silent = true })

        map("n", "<leader>as", function()
            require("sidekick.cli").select()
        end, { desc = "Select CLI tool", noremap = true, silent = true })

        map("n", "<leader>ad", function()
            require("sidekick.cli").close()
        end, { desc = "Close CLI session", noremap = true, silent = true })

        map({ "n", "x" }, "<leader>at", function()
            require("sidekick.cli").send({ msg = "{this}" })
        end, { desc = "Send this (position/selection)", noremap = true, silent = true })

        map("n", "<leader>af", function()
            require("sidekick.cli").send({ msg = "{file}" })
        end, { desc = "Send file", noremap = true, silent = true })

        map("x", "<leader>av", function()
            require("sidekick.cli").send({ msg = "{selection}" })
        end, { desc = "Send selection", noremap = true, silent = true })

        map({ "n", "x" }, "<leader>ap", function()
            require("sidekick.cli").prompt()
        end, { desc = "Select prompt", noremap = true, silent = true })

        map({ "n", "i" }, "<Tab>", function()
            if require("sidekick").nes_jump_or_apply() then
                return -- jumped or applied
            end
            return "<Tab>"
        end, { expr = true, desc = "Next Edit Suggestion: jump/apply", noremap = true })
    end,
}
