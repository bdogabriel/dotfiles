vim.cmd.colorscheme("rose-pine")

-- setup socket for remote neovim access (nvr/lazygit integration)
-- uses socket defined in shell (unique per tmux pane or default)
-- this ensures lazygit and other tools can communicate with the main nvim instance
local socket_addr = os.getenv("NVIM_LISTEN_ADDRESS")
if socket_addr and os.getenv("NVIM") == nil then
    -- not inside a nested session, setup the server
    vim.fn.servername(socket_addr)
end

local mdx_id = vim.api.nvim_create_augroup("mdx", {
    clear = false,
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = mdx_id,
    pattern = "*.mdx",
    callback = function()
        vim.o.filetype = "markdown"
    end,
})

-- auto-delete buffers for git filetypes
local git_id = vim.api.nvim_create_augroup("git", {
    clear = true,
})

vim.api.nvim_create_autocmd("FileType", {
    group = git_id,
    pattern = { "gitcommit", "gitrebase", "gitconfig" },
    callback = function()
        vim.o.bufhidden = "delete"
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ timeout = 500 })
    end,
})
