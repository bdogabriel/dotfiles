return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim",
	},
	config = function()
		require("neogit").setup({
			commit_editor = {
				staged_diff_split_kind = "auto",
			},
		})

		vim.keymap.set("n", "<leader>gg", "<CMD>Neogit<CR>", { desc = "Neogit", noremap = true, silent = true })
	end,
}
