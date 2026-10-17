return {
	"gbprod/yanky.nvim",
	opts = {},
	keys = {
		{
			"<leader>yh",
			function()
				require("yanky.picker").select_in_history()
			end,
			mode = { "n", "x" },
			desc = "Open Yank History",
		},
	},
}
