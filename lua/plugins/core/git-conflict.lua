local diff_colors = {
	delete = "#681300",
	add = "#055800",
	change = "#105090",
	base_text = "#000000",
	text_fg = "#ffffff",
}

return {
	"akinsho/git-conflict.nvim",
	version = "*",
	lazy = false,
	enabled = false,
	dependencies = {
		"echasnovski/mini.nvim",
	},
	config = function()
		vim.api.nvim_set_hl(0, "DiffTextConflict", {
			fg = "#000000",
			bg = diff_colors.delete,
		})
		vim.api.nvim_set_hl(
			0,
			"DiffAddConflict",
			{ fg = "#ffffff", bg = diff_colors.add }
		)
		vim.api.nvim_set_hl(
			0,
			"DiffDeleteConflict",
			{ fg = "#ffffff", bg = diff_colors.delete }
		)
		vim.api.nvim_set_hl(
			0,
			"DiffChangeConflict",
			{ fg = diff_colors.text_fg, bg = diff_colors.change }
		)
		require('git-conflict').setup {
			default_mappings = true, -- disable buffer local mapping created by this plugin
			disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted

			-- They must have background color, otherwise the default color will be used
			highlights = {
				incoming = "DiffDeleteConflict",
				current = "DiffAddConflict",
				ancestor = "DiffTextConflict",
				changed = "DiffChangeConflict",
			},
		}
	end,
	cmd = {
		"GitConflictListQf",
		"GitConflictNextConflict",
		"GitConflictPrevConflict",
		"GitConflictRefresh",
		"GitConflictChooseBase",
		"GitConflictChooseBoth",
		"GitConflictChooseNone",
		"GitConflictChooseTheirs",
		"GitConflictChooseOurs",
	},
	keys = {
		{
			"<leader>cq",
			"<cmd>ConflictsQF<cr>",
			desc = "Git Conflict List Quickfix",
		},
		{
			"]x",
			"<cmd>GitConflictNextConflict<cr>",
			desc = "Next Git Conflict",
		},
		{
			"[x",
			"<cmd>GitConflictPrevConflict<cr>",
			desc = "Previous Git Conflict",
		},
		-- { "<leader>co", "<cmd>GitConflictChooseOurs<cr>", desc = "Choose Ours" },
		-- { "<leader>ct", "<cmd>GitConflictChooseTheirs<cr>", desc = "Choose Theirs" },
		-- { "<leader>cb", "<cmd>GitConflictChooseBoth<cr>", desc = "Choose Both" },
		-- { "<leader>c0", "<cmd>GitConflictChooseNone<cr>", desc = "Choose None" },
	},
}
