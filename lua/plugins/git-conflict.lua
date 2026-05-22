return {
	"akinsho/git-conflict.nvim",
	version = "*",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "lewis6991/gitsigns.nvim" },
	config = function()
		require "gitsigns"
		local function setup()
			local light = vim.o.background == "light"
			vim.api.nvim_set_hl(
				0,
				"GitConflictCurrentBg",
				{ bg = light and "#fff0e0" or "#5a1525" }
			)
			vim.api.nvim_set_hl(
				0,
				"GitConflictIncomingBg",
				{ bg = light and "#f0fff0" or "#155a25" }
			)
			vim.api.nvim_set_hl(
				0,
				"GitConflictAncestorBg",
				{ bg = light and "#f0f0ff" or "#15255a" }
			)

			require("git-conflict").setup {
				default_mappings = true,
				default_commands = true,
				disable_diagnostics = false,
				list_opener = "copen",
				highlights = {
					current = "GitConflictCurrentBg",
					incoming = "GitConflictIncomingBg",
					ancestor = "GitConflictAncestorBg",
				},
			}
		end

		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = setup,
		})

		setup()
	end,
}
