return {
    "johmsalas/text-case.nvim",
    config = function()
        require("textcase").setup({
            prefix = "gC",
        })
    end,
    cmd = {
        "Subs",
        "TextCaseStartReplacingCommand",
    },
    lazy = false,
}
