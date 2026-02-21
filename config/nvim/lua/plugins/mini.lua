return {
    "echasnovski/mini.nvim",
    lazy = false,
    config = function()
        ---- clue ----
        local clue = require("mini.clue")
        clue.setup({
            triggers = {
                -- Leader triggers
                { mode = "n", keys = "<leader>" },
                { mode = "x", keys = "<leader>" },

                -- Local Leader triggers
                { mode = "n", keys = "<localleader>" },
                { mode = "x", keys = "<localleader>" },

                -- Built-in completion
                { mode = "i", keys = "<C-x>" },

                -- `g` key
                { mode = "n", keys = "g" },
                { mode = "x", keys = "g" },

                -- Marks
                { mode = "n", keys = "'" },
                { mode = "n", keys = "`" },
                { mode = "x", keys = "'" },
                { mode = "x", keys = "`" },

                -- Registers
                { mode = "n", keys = '"' },
                { mode = "x", keys = '"' },

                -- `z` key
                { mode = "n", keys = "z" },
                { mode = "x", keys = "z" },
            },
            clues = {
                clue.gen_clues.builtin_completion(),
                clue.gen_clues.g(),
                clue.gen_clues.marks(),
                clue.gen_clues.registers(),
                clue.gen_clues.windows(),
                clue.gen_clues.z(),

                { mode = "n", keys = "<leader>c", desc = "Code" },
                { mode = "n", keys = "<leader>ct", desc = "Toggle" },
                { mode = "n", keys = "<leader>d", desc = "Debugger" },
                { mode = "n", keys = "<leader>g", desc = "Git" },
                { mode = "n", keys = "<leader>gt", desc = "Toggle" },
                { mode = "n", keys = "<leader>h", desc = "Harpoon" },
                { mode = "n", keys = "<leader>l", desc = "LSP" },
                { mode = "n", keys = "<leader>m", desc = "Mark" },
                { mode = "n", keys = "<leader>p", desc = "Project (session)" },
                { mode = "n", keys = "<leader>q", desc = "Quickfix" },
                { mode = "n", keys = "<leader>qm", desc = "Apply macro" },
                { mode = "n", keys = "<leader>r", desc = "Request" },
                { mode = "n", keys = "<leader>s", desc = "Search" },
                { mode = "n", keys = "<leader>t", desc = "Toggle" },
                { mode = "n", keys = "<leader>v", desc = "Diffview" },
                { mode = "n", keys = "<leader>x", desc = "VimTex" },
                { mode = "n", keys = "gC", desc = "Text case" },
                { mode = "n", keys = "gCo", desc = "Operator" },
                { mode = "x", keys = "gC", desc = "Text case" },
                { mode = "x", keys = "gCo", desc = "Operator" },
            },
            window = {
                config = {
                    width = "auto",
                    border = "rounded",
                },
            },
        })
        ---- end of clue ----

        ---- files ----
        local files = require("mini.files")
        files.setup({
            windows = {
                preview = true,
                width_preview = 50,
                width_focus = 30,
                width_nofocus = 20,
            },
            mappings = {
                go_in = "",
            },
        })

        local mini_files_toggle = function()
            if not files.close() then
                local buf_path = vim.api.nvim_buf_get_name(0)
                local target = vim.loop.fs_realpath(buf_path) or buf_path -- Resolve symlinks

                if target == "" then -- For unnamed buffers
                    target = vim.fn.getcwd()
                else
                    target = vim.fs.dirname(target)
                end

                files.open(target)
            end
        end

        vim.keymap.set("n", "<leader>e", mini_files_toggle, { desc = "Explorer" })

        vim.keymap.set("n", "<Esc>", function()
            vim.cmd.nohlsearch()
            files.close()
        end, { noremap = true, silent = true })

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesActionRename",
            desc = "Handle file renaming with Snacks",
            callback = function(event)
                Snacks.rename.on_rename_file(event.data.from, event.data.to)
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesWindowOpen",
            desc = "Add rounded borders to mini.files windows",
            callback = function(args)
                local win_id = args.data.win_id
                local config = vim.api.nvim_win_get_config(win_id)
                config.border = "rounded"
                vim.api.nvim_win_set_config(win_id, config)
            end,
        })

        local expand_single_dir
        expand_single_dir = vim.schedule_wrap(function()
            local is_one_dir = vim.api.nvim_buf_line_count(0) == 1
                and (MiniFiles.get_fs_entry() or {}).fs_type == "directory"
            if not is_one_dir then
                return
            end
            MiniFiles.go_in()
            expand_single_dir()
        end)

        local go_in_and_expand = function()
            MiniFiles.go_in()
            expand_single_dir()
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                vim.keymap.set("n", "l", go_in_and_expand, { buffer = args.data.buf_id })
            end,
        })
        ---- end of files ----

        local spec_treesitter = require("mini.ai").gen_spec.treesitter
        local spec_pair = require("mini.ai").gen_spec.pair
        require("mini.ai").setup({
            custom_textobjects = {
                f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
                o = spec_treesitter({
                    a = { "@conditional.outer", "@loop.outer" },
                    i = { "@conditional.inner", "@loop.inner" },
                }),
                u = spec_pair("_", "_", { type = "greedy" }),
            },
        })
        require("mini.align").setup({
            mappings = {
                start = "ga",
                start_with_preview = "gA",
            },
        })
        require("mini.bracketed").setup()
        require("mini.comment").setup()
        require("mini.cursorword").setup()
        require("mini.move").setup({
            mappings = {
                left = "<M-C-h>",
                right = "<M-C-l>",
                down = "<M-C-j>",
                up = "<M-C-k>",
                line_left = "<M-C-h>",
                line_right = "<M-C-l>",
                line_down = "<M-C-j>",
                line_up = "<M-C-k>",
            },
        })
        require("mini.operators").setup()
        require("mini.pairs").setup()
        require("mini.splitjoin").setup()
        require("mini.surround").setup()
    end,
}
