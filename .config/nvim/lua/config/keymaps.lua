local map = vim.keymap.set

map({ "n" }, "<Esc>", "<CMD>nohlsearch<CR>", { noremap = true, silent = true })

---- tabs ----
map("n", "<leader><tab>", "<CMD>tabclose<CR>", { desc = "Tab: close", noremap = true, silent = true })
map("n", "<M-`>", "<CMD>tabnext<CR>", { desc = "Tab: next", noremap = true, silent = true })
---- end of tabs ----

---- splits (windows) ----
map({ "n", "v" }, "<leader>H", "<CMD>leftabove vsplit<CR>", { desc = "Window: split left" })
map({ "n", "v" }, "<leader>J", "<CMD>rightbelow split<CR>", { desc = "Window: split down" })
map({ "n", "v" }, "<leader>K", "<CMD>leftabove split<CR>", { desc = "Window: split up" })
map({ "n", "v" }, "<leader>L", "<CMD>rightbelow vsplit<CR>", { desc = "Window: split right" })

map(
    { "n", "v" },
    "<M-h>",
    "<CMD>vertical resize -5<CR>",
    { desc = "Window: resize 5 right", noremap = true, silent = true }
)
map({ "n", "v" }, "<M-j>", "<CMD>resize -5<CR>", { desc = "Window: resize 5 down", noremap = true, silent = true })
map({ "n", "v" }, "<M-k>", "<CMD>resize +5<CR>", { desc = "Window: resize 5 up", noremap = true, silent = true })
map(
    { "n", "v" },
    "<M-l>",
    "<CMD>vertical resize +5<CR>",
    { desc = "Window: resize 5 left", noremap = true, silent = true }
)

map({ "n", "v" }, "<leader>w", "<C-w>c", { desc = "Window: close", noremap = true, silent = true })
map({ "n", "v" }, "<leader>W", "<C-w>o", { desc = "Window: focus (close others)", noremap = true, silent = true })
---- end of splits ----

---- quit ----
map("n", "<leader>Q", "<CMD>wall<CR><CMD>qall<CR>", { desc = "Save all and quit", noremap = true, silent = true })
map("n", "<leader>!", "<CMD>qall!<CR>", { desc = "Quit without saving", noremap = true, silent = true })
---- end of quit ----

---- code ----
map("n", "H", function()
    vim.lsp.buf.hover({
        border = "rounded",
    })
end, { desc = "LSP hover", silent = true })
map("n", "<leader>ck", function()
    vim.lsp.buf.signature_help({
        border = "rounded",
    })
end, { desc = "LSP signature help", silent = true })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Action" })
map("n", "<leader>co", vim.diagnostic.open_float, { desc = "Open diagnostics in float" })
---- end of code ----

--- marks ----
map("n", "<leader>mD", ":delmarks!<CR>", { desc = "Delete all (a-z, A-Z, 0-9)" })
map("n", "<leader>md", function()
    local line = vim.fn.line(".") -- Get current line number
    local marks = vim.fn.execute("marks") -- Get all marks
    for mark in marks:gmatch("[a-zA-Z0-9]") do -- Iterate through marks
        local mark_line = vim.fn.line("'" .. mark) -- Get line number of mark
        if mark_line == line then
            vim.cmd("delmarks " .. mark) -- Delete if on current line
            print("Deleted mark: " .. mark)
        end
    end
end, { desc = "Delete on current line" })
--- end of marks ----

---- quickfix ----
map("n", "<leader>qo", "<CMD>copen<CR>", { desc = "Open", noremap = true, silent = true })
map("n", "<leader>qc", "<CMD>cclose<CR>", { desc = "Close", noremap = true, silent = true })
map("n", "<leader>qi", ":cc ", { desc = "Item", noremap = true, silent = true })
map("n", "<leader>qd", ":cdo ", { desc = "Do", noremap = true, silent = true })
map("n", "<leader>qD", ":cfdo ", { desc = "File do (instead of entry)", noremap = true, silent = true })
map("n", "<leader>qmq", '<CMD>cdo execute "norm! @q" | update<CR>', { desc = "@q", noremap = true, silent = true })
map("n", "<leader>qma", '<CMD>cdo execute "norm! @a" | update<CR>', { desc = "@a", noremap = true, silent = true })
---- end of quickfix ----

map("t", "<C-n>", [[<C-\><C-n>]], { noremap = true, silent = true })
