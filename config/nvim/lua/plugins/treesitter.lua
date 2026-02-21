return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    dependencies = {
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            branch = "main",
        },
        {
            "nvim-treesitter/nvim-treesitter-context",
        },
    },
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install({
            "bash",
            "c",
            "cpp",
            "c_sharp",
            "css",
            "gdscript",
            "go",
            "graphql",
            "html",
            "http",
            "java",
            "javascript",
            "json",
            "kotlin",
            "latex",
            "lua",
            "markdown",
            "regex",
            "rego",
            "sql",
            "toml",
            "typescript",
            "xml",
            "yaml",
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "C",
                "bash",
                "c",
                "cpp",
                "cs",
                "css",
                "gdscript",
                "go",
                "gql",
                "graphql",
                "html",
                "http",
                "java",
                "js",
                "jsx",
                "json",
                "kt",
                "lua",
                "md",
                "rego",
                "sql",
                "tex",
                "toml",
                "ts",
                "tsx",
                "xml",
                "yaml",
                "yml",
            },
            callback = function()
                -- syntax highlighting, provided by Neovim
                vim.treesitter.start()
                -- folds, provided by Neovim
                vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.wo.foldmethod = "expr"
                -- indentation, provided by nvim-treesitter
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
