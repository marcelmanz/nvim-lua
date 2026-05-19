-- TODO: Check if this is still necesary now that we have the custom ConflictsQF command
return {
	"niekdomi/conflict.nvim",
	enabled = false,
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
