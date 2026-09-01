return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local isRecording = function()
            local reg = vim.fn.reg_recording()
            if reg == "" then
                return ""
            end -- not recording
            return "recording @" .. reg
        end
        require("lualine").setup({
            sections = {
                lualine_b = { "branch" },
                lualine_c = {
                    { "filename", path = 1 },
                    "diagnostics",
                    "diff",
                },
                lualine_x = {
                    {
                        isRecording,
                        color = { fg = "#ff9e64" },
                    },
                    "searchcount",
                    "encoding",
                    "fileformat",
                    "filetype",
                    "lsp_status",
                },
            },
            options = {
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
            },
            extensions = {
                "lazy",
                "mason",
                "quickfix",
            },
        })
    end,
}
