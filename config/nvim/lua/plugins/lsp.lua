return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { "williamboman/mason.nvim", opts = {} },
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
        -- Setup LSP capabilities with document highlighting support
        local nvim_capabilities = vim.lsp.protocol.make_client_capabilities()
        nvim_capabilities.textDocument = nvim_capabilities.textDocument or {}
        nvim_capabilities.textDocument.documentHighlight = {
            dynamicRegistration = false,
        }
        local capabilities = require("blink.cmp").get_lsp_capabilities(nvim_capabilities)

        -- Diagnostic Config
        vim.diagnostic.config({
            virtual_text = false,
            severity_sort = true,
            underline = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = " ",
                    [vim.diagnostic.severity.WARN] = " ",
                    [vim.diagnostic.severity.INFO] = " ",
                    [vim.diagnostic.severity.HINT] = " ",
                },
            },
        })

        -- Setup LSP when attaching to a buffer
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            desc = "Configure LSP features when an LSP attaches to a buffer",
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)

                -- Only setup document highlight if the server supports it
                if client.server_capabilities.documentHighlightProvider then
                    local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })

                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        desc = "Highlight references of the symbol under cursor",
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        desc = "Clear highlighted references when cursor moves",
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd("LspDetach", {
                        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                        desc = "Clean up LSP highlights when an LSP detaches from a buffer",
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end
            end,
        })

        local servers = {
            gdscript = {
                cmd = { "nc", "127.0.0.1", "6005" },
                root_dir = function(_, on_dir)
                    on_dir(vim.fn.getcwd())
                end,
                filetypes = { "gdscript", "gdscript3" },
                capabilities = capabilities,
            },
        }

        for server_name, config in pairs(servers) do
            vim.lsp.config(server_name, config)
            vim.lsp.enable(server_name)
        end

        local mason_servers = {
            bashls = {},
            clangd = {},
            cssls = {},
            gopls = {},
            graphql = {},
            html = {},
            jdtls = {
                capabilities = {
                    textDocument = {
                        documentHighlight = {
                            dynamicRegistration = false,
                        },
                    },
                },
            },
            kotlin_lsp = {
                jre_path = os.getenv("JDK21"),
            },
            lua_ls = {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            },
            marksman = {},
            omnisharp = {
                root_dir = function(_, on_dir)
                    on_dir(vim.fn.getcwd())
                end,
                settings = {
                    OmniSharp = {
                        EnableMsBuildLoadProjectsOnDemand = false,
                        UseGlobalMono = "never",
                    },
                    FormattingOptions = {
                        EnableEditorConfigSupport = true,
                    },
                },
                enable_roslyn_analyzers = true,
                enable_import_completion = true,
                single_file_support = true,
            },
            pylsp = {},
            regal = {},
            sqlls = {},
            tailwindcss = {},
            texlab = {},
            ts_ls = {
                typescript = {
                    format = {
                        enabled = false,
                    },
                },
                javascript = {
                    format = {
                        enabled = false,
                    },
                },
            },
            yamlls = {},
        }

        local ensure_installed = vim.tbl_keys(mason_servers or {})
        vim.list_extend(ensure_installed, {
            "biome",
            "clang-format",
            "gdtoolkit",
            "google-java-format",
            "ktlint",
            "kube-linter",
            "kulala-fmt",
            "mdformat",
            "opa",
            "prettierd",
            "shfmt",
            "sleek",
            "stylelint",
            "stylua",
            "taplo",
            "tex-fmt",
            "yamllint",
            "yamlfmt",
        })

        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        for server_name, server_config in pairs(mason_servers) do
            local config = vim.tbl_deep_extend("force", {
                capabilities = capabilities,
            }, server_config)
            vim.lsp.config(server_name, config)
        end

        require("mason-lspconfig").setup()
    end,
}
