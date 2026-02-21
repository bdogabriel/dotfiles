return {
    "mistweaverco/kulala.nvim",
    keys = {
        {
            "<leader>rs",
            desc = "Send request",
            function()
                require("kulala").run()
            end,
            mode = { "n", "v" },
        },
        {
            "<leader>ra",
            desc = "Send all requests",
            function()
                require("kulala").run_all()
            end,
            mode = { "n", "v" },
        },
        {
            "<leader>rb",
            desc = "Open scratchpad",
            function()
                require("kulala").scratchpad()
            end,
        },
        {
            "<leader>ro",
            desc = "Open kulala",
            function()
                require("kulala").open()
            end,
        },

        {
            "<leader>rt",
            desc = "Toggle headers/body",
            function()
                require("kulala").toggle_view()
            end,
            ft = { "http", "rest" },
        },
        {
            "<leader>rS",
            desc = "Show stats",
            function()
                require("kulala").show_stats()
            end,
            ft = { "http", "rest" },
        },

        {
            "<leader>rq",
            desc = "Close window",
            function()
                require("kulala").close()
            end,
            ft = { "http", "rest" },
        },

        {
            "<leader>rc",
            desc = "Copy as cURL",
            function()
                require("kulala").copy()
            end,
            ft = { "http", "rest" },
        },
        {
            "<leader>rC",
            desc = "Paste from curl",
            function()
                require("kulala").from_curl()
            end,
            ft = { "http", "rest" },
        },

        {
            "<CR>",
            desc = "Send request",
            function()
                require("kulala").run()
            end,
            mode = { "n", "v" },
            ft = { "http", "rest" },
        },

        {
            "<leader>ri",
            desc = "Inspect current request",
            function()
                require("kulala").inspect()
            end,
            ft = { "http", "rest" },
        },
        {
            "<leader>rr",
            desc = "Replay the last request",
            function()
                require("kulala").replay()
            end,
        },

        {
            "<leader>rf",
            desc = "Find request",
            function()
                require("kulala").search()
            end,
            ft = { "http", "rest" },
        },
        {
            "<leader>rn",
            desc = "Jump to next request",
            function()
                require("kulala").jump_next()
            end,
            ft = { "http", "rest" },
        },
        {
            "<leader>rp",
            desc = "Jump to previous request",
            function()
                require("kulala").jump_prev()
            end,
            ft = { "http", "rest" },
        },

        {
            "<leader>re",
            desc = "Select environment",
            function()
                require("kulala").set_selected_env()
            end,
            ft = { "http", "rest" },
        },
        {
            "<leader>ru",
            desc = "Manage Auth Config",
            function()
                require("lua.kulala.ui.auth_manager").open_auth_config()
            end,
            ft = { "http", "rest" },
        },
        {
            "<leader>rg",
            desc = "Download GraphQL schema",
            function()
                require("kulala").download_graphql_schema()
            end,
            ft = { "http", "rest" },
        },

        {
            "<leader>rx",
            desc = "Clear globals",
            function()
                require("kulala").scripts_clear_global()
            end,
            ft = { "http", "rest" },
        },
        {
            "<leader>rX",
            desc = "Clear cached files",
            function()
                require("kulala").clear_cached_files()
            end,
            ft = { "http", "rest" },
        },
    },
    ft = { "http", "rest" },
    opts = {
        global_keymaps = true,
        global_keymaps_prefix = "<leader>r",
        kulala_keymaps_prefix = "",
        ui = {
            icons = {
                inlay = {
                    loading = "󰥔 ",
                    done = " ",
                    error = " ",
                },
                lualine = "󰏚 ",
                textHighlight = "WarningMsg",
            },
        },
    },
}
