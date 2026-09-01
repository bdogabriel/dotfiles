return {
    "stevearc/conform.nvim",
    config = function()
        local conform = require("conform")
        conform.setup({
            notify_on_error = true,
            formatters_by_ft = {
                bash = { "shfmt" },
                c = { "clang_format" },
                cpp = { "clang_format" },
                cs = { "clang_format" },
                css = { "stylelint" },
                go = { "goimports", "gofmt" },
                graphql = { "prettierd" },
                html = { "biome" },
                http = { "kulala" },
                java = { "google-java-format" },
                javascript = { "biome" },
                json = { "biome" },
                kotlin = { "ktlint" },
                lua = { "stylua" },
                rego = { "opa" },
                sql = { "sleek" },
                toml = { "taplo" },
                typescript = { "biome" },
                yaml = { "yamlfmt" },
            },
            formatters = {
                clang_format = {
                    prepend_args = { "--style=Microsoft", "--fallback-style=LLVM" },
                },
                kulala = {
                    command = "kulala-fmt",
                    args = { "format", "$FILENAME" },
                    stdin = false,
                },
                opa = {
                    command = "opa",
                    args = { "fmt", "--write", "$FILENAME" },
                    stdin = false,
                },
                shfmt = {
                    prepend_args = { "-i", "4" },
                },
                ["google-java-format"] = {
                    command = "google-java-format",
                    args = { "--aosp", "--replace", "$FILENAME" },
                    stdin = false,
                },
            },
        })

        vim.keymap.set("n", "<leader>cf", function()
            conform.format({
                async = true,
                lsp_format = "fallback",
            })
        end, { desc = "Format" })
    end,
}
