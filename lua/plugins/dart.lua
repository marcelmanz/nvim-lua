return {
	"marcelarie/dart.nvim",
	-- dir = vim.fn.expand "$HOME/clones/forks/dart.nvim",
	-- name = "dart.nvim",
	enabled = true,
	lazy = true,
	keys = {
		{ ";;", desc = "Mark current buffer" },
		{ ";", desc = "Jump to buffer" },
		{ ";p", desc = "Open Dart.pick" },
		{ ";u", desc = "Close all marked buffers" },
	},
	opts = {
		marklist = { "a", "s", "d", "f", "q", "w", "e", "r" },
		-- buflist = { "z", "x", "c" },
		buflist = {},
		tabline = {
			always_show = true,
			cycle_wraps_around = true,
			icons = false,
			label_fg = "orange",
			current_bg = "black",
			visible_bg = "black",
			modified_bg = "black",
		},
		picker = {
			path_format = ":~",
			border = "single",
		},
		persist = {
			path = vim.fn.stdpath "data" .. "/dart",
		},
		mappings = {
			mark = ";;", -- Mark current buffer
			jump = ";", -- Jump to buffer marked by next character i.e `;a`
			pick = ";p", -- Open Dart.pick
			next = "<S-l>", -- Cycle right through the tabline
			prev = "<S-h>", -- Cycle left through the tabline
			unmark_all = ";u", -- Close all marked and recent buffers
		},
	},
}
