return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
        local ufo = require("ufo")
        ufo.setup({
            provider_selector = function(bufnr, filetype, buftype)
                return { "lsp", "indent" }
            end,
        })

        vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
        vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
    end,
}
