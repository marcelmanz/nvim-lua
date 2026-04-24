return {
	"themarcel/conflict.nvim",
	config = function()
		require("conflict").setup {}
	end,
	keys = {
		{
			"<leader>cl",
			"<cmd>Conflict list<cr>",
			desc = "Git Conflict List",
		},
		{
			"<leader>cq",
			"<cmd>Conflict qflist<cr>",
			desc = "Git Conflict Quickfix List",
		},
	},
}
