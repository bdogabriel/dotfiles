return {
    "rmagatti/auto-session",
    lazy = false,
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        legacy_cmds = false,
        show_auto_restore_notif = true,
        suppressed_dirs = {
            "~/",
            "~/Downloads/",
            "~/Documents/",
            "/tmp/",
            "/private/tmp/",
        },
        pre_save_cmds = {
            function()
                vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
            end,
        },
        session_lens = {
            picker = "snacks",
            theme = "default",
        },
        git_use_branch_name = false,
        bypass_save_filetypes = {
            "alpha",
            "dashboard",
            "snacks_dashboard",
        },
        close_unsupported_windows = true,
        continue_restore_on_error = true,
    },

    keys = {
        -- Migrate your existing keymaps
        { "<leader>po", "<cmd>AutoSession search<CR>", desc = "Open" },
        {
            "<leader>pw",
            function()
                local dir_name = vim.fs.basename(vim.fn.getcwd())
                local name = vim.fn.input("Session name: ", dir_name)
                if name ~= "" then
                    vim.cmd("AutoSession save " .. name)
                end
            end,
            desc = "Write (prompt)",
        },
        { "<leader>pd", "<cmd>AutoSession deletePicker<CR>", desc = "Delete" },
        { "<leader>pr", "<cmd>AutoSession restore<CR>", desc = "Restore" },
        { "<leader>pt", "<cmd>AutoSession toggle<CR>", desc = "Toggle autosave" },
    },
}
