return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        animate = { enabled = true },
        bigfile = { enabled = true },
        bufdelete = { enabled = true },
        image = { enabled = true },
        indent = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 2000,
            margin = { top = 1, right = 1, bottom = 1 },
            padding = false,
            filter = function(n)
                if n.msg == "Couldn't find buffer" then
                    return false
                end
                return true
            end,
        },
        rename = { enabled = true },
        picker = {
            enabled = true,
            win = {
                input = {
                    keys = {
                        ["<M-q>"] = { "qflist", mode = { "i", "n" } },
                    },
                },
                list = {
                    keys = {
                        ["<M-q>"] = "qflist",
                    },
                },
            },
        },
        styles = {
            notification = { wo = {
                wrap = true,
                winblend = 25,
            } },
            notification_history = {
                wo = { wrap = true },
                keys = { q = "close" },
            },
        },
    },
    keys = {
        {
            "<leader>P",
            function()
                Snacks.picker()
            end,
            desc = "Picker: select picker",
        },
        -- File search and navigation
        {
            "<leader>f",
            function()
                Snacks.picker.files({ hidden = true })
            end,
            desc = "Search: file",
        },
        {
            "<leader>/",
            function()
                Snacks.picker.grep({ hidden = true })
            end,
            desc = "Live grep",
        },
        {
            "<leader>,",
            function()
                Snacks.picker.buffers({
                    win = {
                        input = {
                            keys = {
                                ["<c-d>"] = { "bufdelete", mode = { "n", "i" } },
                                ["dd"] = { "bufdelete", mode = { "n" } },
                            },
                        },
                        list = { keys = { ["dd"] = "bufdelete" } },
                    },
                })
            end,
            desc = "Buffer",
        },
        -- Git pickers
        {
            "<leader>sB",
            function()
                Snacks.picker.git_branches()
            end,
            desc = "Git: branches",
        },
        {
            "<leader>sC",
            function()
                Snacks.picker.git_log()
            end,
            desc = "Git: commits",
        },
        {
            "<leader>sc",
            function()
                Snacks.picker.git_log_file()
            end,
            desc = "Git: buffer commits",
        },
        {
            "<leader>ss",
            function()
                Snacks.picker.git_status()
            end,
            desc = "Git: status",
        },
        {
            "<leader>sS",
            function()
                Snacks.picker.git_stash()
            end,
            desc = "Git: stash",
        },
        -- Search and navigation
        {
            "<leader>s:",
            function()
                Snacks.picker.command_history()
            end,
            desc = "Command history",
        },
        {
            '<leader>s"',
            function()
                Snacks.picker.registers()
            end,
            desc = "Registers",
        },
        {
            "<leader>s/",
            function()
                Snacks.picker.search_history()
            end,
            desc = "Search history",
        },
        {
            "<leader>sa",
            function()
                Snacks.picker.autocmds()
            end,
            desc = "Autocmds",
        },
        {
            "<leader>s;",
            function()
                Snacks.picker.commands()
            end,
            desc = "Commands",
        },
        {
            "<leader>sd",
            function()
                Snacks.picker.diagnostics_buffer()
            end,
            desc = "Buffer diagnostics",
        },
        {
            "<leader>sD",
            function()
                Snacks.picker.diagnostics()
            end,
            desc = "Diagnostics",
        },
        {
            "<leader>sh",
            function()
                Snacks.picker.help({
                    confirm = function(picker)
                        local item = picker:current()
                        if item then
                            picker:close()
                            vim.cmd("vertical help " .. item.text)
                        end
                    end,
                })
            end,
            desc = "Help tags",
        },
        {
            "<leader>sH",
            function()
                Snacks.picker.man({
                    confirm = function(picker, item)
                        picker:close()
                        if item then
                            vim.schedule(function()
                                vim.cmd("vertical Man " .. item.ref)
                            end)
                        end
                    end,
                })
            end,
            desc = "Man pages",
        },
        {
            "<leader>sj",
            function()
                Snacks.picker.jumps()
            end,
            desc = "Jump list",
        },
        {
            "<leader>sk",
            function()
                Snacks.picker.keymaps()
            end,
            desc = "Keymaps",
        },
        {
            "<leader>sl",
            function()
                Snacks.picker.loclist()
            end,
            desc = "Location list",
        },
        {
            "<leader>sm",
            function()
                Snacks.picker.marks()
            end,
            desc = "Marks",
        },
        {
            "<leader>sq",
            function()
                Snacks.picker.qflist()
            end,
            desc = "Quickfix list",
        },
        {
            "<leader>sr",
            function()
                Snacks.picker.resume()
            end,
            desc = "Resume last search",
        },
        {
            "<leader>su",
            function()
                Snacks.picker.undo()
            end,
            desc = "Undo history",
        },
        {
            "<leader>sv",
            function()
                Snacks.picker.colorschemes()
            end,
            desc = "Colorscheme",
        },
        -- LSP pickers
        {
            "<C-e>",
            function()
                Snacks.picker.lsp_references()
            end,
            desc = "LSP: references",
        },
        {
            "J",
            function()
                Snacks.picker.lsp_definitions()
            end,
            desc = "LSP: definitions",
        },
        {
            "<C-a>",
            function()
                Snacks.picker.lsp_declarations()
            end,
            desc = "LSP: declarations",
        },
        {
            "<C-f>",
            function()
                Snacks.picker.lsp_implementations()
            end,
            desc = "LSP: implementations",
        },
        {
            "<C-y>",
            function()
                Snacks.picker.lsp_type_definitions()
            end,
            desc = "LSP: type definitions",
        },
        {
            "<leader>Y",
            function()
                Snacks.picker.lsp_workspace_symbols()
            end,
            desc = "LSP: workspace symbols",
        },
        {
            "<leader>y",
            function()
                Snacks.picker.lsp_symbols()
            end,
            desc = "LSP: symbols",
        },
        -- Original snacks functionality
        {
            "<leader>b",
            function()
                Snacks.bufdelete.delete()
            end,
            desc = "Buffer: delete",
            mode = { "n" },
        },
        {
            "<leader>.",
            function()
                Snacks.scratch()
            end,
            desc = "Scratch buffer",
        },
        {
            "<leader>n",
            function()
                Snacks.notifier.show_history()
            end,
            desc = "Notification history",
        },
        {
            "<leader>gB",
            function()
                Snacks.gitbrowse()
            end,
            desc = "Browse",
            mode = { "n", "v" },
        },
        {
            "<leader>R",
            function()
                Snacks.rename.rename_file()
            end,
            desc = "Rename file",
        },
    },
    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            desc = "Setup globals for debugging and toggle mappings",
            callback = function()
                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command

                -- Create some toggle mappings
                Snacks.toggle.option("spell"):map("<leader>ts", { desc = "Spelling" })
                Snacks.toggle.option("wrap"):map("<leader>tw", { desc = "Wrap" })
                Snacks.toggle.option("relativenumber"):map("<leader>tr", { desc = "Line relative number" })
                Snacks.toggle.option("number", { name = "Number" }):map("<leader>tn", { desc = "Line number" })
                Snacks.toggle.diagnostics():map("<leader>td", { desc = "Diagnostics" })
                Snacks.toggle.treesitter():map("<leader>tT", { desc = "Treesitter highlight" })
                Snacks.toggle.inlay_hints():map("<leader>th", { desc = "Inlay hints" })
                Snacks.toggle.indent():map("<leader>ti", { desc = "Indent lines" })
                Snacks.toggle.dim():map("<leader>td", { desc = "Dimming" })
            end,
        })

        -- turn Snacks off while the cmp menu is open, turn it back on afterward
        local group = vim.api.nvim_create_augroup("BlinkCmpSnacksToggle", { clear = true })

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "BlinkCmpMenuOpen",
            callback = function()
                vim.g.snacks_animate = false
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "BlinkCmpMenuClose",
            callback = function()
                vim.g.snacks_animate = true
            end,
        })

        vim.ui.select = require("snacks").picker.select
    end,
}
