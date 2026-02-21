return {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "jay-babu/mason-nvim-dap.nvim",
            event = "VeryLazy",
            dependencies = {
                "williamboman/mason.nvim",
                "mfussenegger/nvim-dap",
            },
            opts = {
                ensure_installed = {
                    "codelldb",
                },
                handlers = {},
            },
        },
        "nvim-neotest/nvim-nio",
        { "rcarriga/nvim-dap-ui", event = "VeryLazy" },
        { "theHamsta/nvim-dap-virtual-text", opts = {} },
        {
            "jbyuki/one-small-step-for-vimkind",
            keys = {
                {
                    "<leader>dv",
                    function()
                        require("osv").launch({ port = 8086 })
                    end,
                    desc = "Launch OSV",
                    noremap = true,
                    silent = true,
                },
            },
        },
    },
    config = function()
        local dap, dapui = require("dap"), require("dapui")

        dap.adapters = {
            codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "codelldb",
                    args = { "--port", "${port}" },
                },
            },
            nlua = function(callback, config)
                callback({
                    type = "server",
                    host = config.host or "127.0.0.1",
                    port = config.port or 8086,
                })
            end,
            godot = {
                type = "server",
                host = "127.0.0.1",
                port = 6006,
            },
        }

        dap.configurations = {
            cpp = {
                {
                    name = "Launch with input",
                    type = "codelldb",
                    request = "launch",
                    program = "${workspaceFolder}/exe",
                    args = {},
                    cwd = "${workspaceFolder}",
                    stdio = { "${workspaceFolder}/input.in", nil, nil }, -- input redirection
                    -- alternative:
                    lldbArgs = { "--", "-o", "process launch -i ${workspaceFolder}/test-cases/1.in" },
                },
            },
            lua = {
                {
                    type = "nlua",
                    request = "attach",
                    name = "Attach to running Neovim instance",
                },
            },
            gdscript = {
                {
                    type = "godot",
                    request = "launch",
                    name = "Launch scene",
                    project = "${workspaceFolder}",
                    launch_scene = true,
                },
            },
        }

        dapui.setup()

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        vim.keymap.set("n", "<leader>de", function()
            dapui.eval()
        end, { desc = "Evaluate", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dt", function()
            dapui.toggle()
        end, { desc = "Toggle UI", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dr", function()
            dapui.open({ reset = true })
        end, { desc = "Reset UI", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dc", function()
            dap.continue()
        end, { desc = "Continue or start", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>db", function()
            dap.toggle_breakpoint()
        end, { desc = "Toggle breakpoint", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>do", function()
            dap.step_over()
        end, { desc = "Step over", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>di", function()
            dap.step_into()
        end, { desc = "Step into", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dO", function()
            dap.step_out()
        end, { desc = "Step out", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dB", function()
            dap.set_breakpoint()
        end, { desc = "Set breakpoint", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dl", function()
            dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end, { desc = "Set log point", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dR", function()
            dap.repl.open()
        end, { desc = "Open REPL", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dL", function()
            dap.run_last()
        end, { desc = "Run last", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>dq", function()
            dap.terminate()
        end, { desc = "Terminate", noremap = true, silent = true })

        vim.keymap.set({ "n", "v", noremap = true, silent = true }, "<leader>dh", function()
            dapui.widgets.hover()
        end, { desc = "Hover widget", noremap = true, silent = true })

        vim.keymap.set({ "n", "v", noremap = true, silent = true }, "<leader>dp", function()
            dapui.widgets.preview()
        end, { desc = "Preview widget", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>df", function()
            dapui.widgets.centered_float(dapui.widgets.frames)
        end, { desc = "Centered float frames", noremap = true, silent = true })

        vim.keymap.set("n", "<leader>ds", function()
            dapui.widgets.centered_float(dapui.widgets.scopes)
        end, { desc = "Centered float scopes", noremap = true, silent = true })
    end,
}
