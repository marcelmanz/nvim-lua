return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	-- dependencies = { "nvim-tree/nvim-web-devicons" },
	-- or if using mini.icons/mini.nvim
	-- dependencies = { "nvim-mini/mini.icons" },
	opts = {},
	enabled = false,
	config = function()
		local actions = require("fzf-lua").actions
		local config = require "fzf-lua.config"

		config.defaults.keymap.fzf["ctrl-q"] = "accept"

		require("fzf-lua").setup {
			{
				"borderless",
				files = {
					grep = {
						["ctrl-r"] = actions.grep_lgrep,
					},
				},
				keymap = {
					fzf = { ["ctrl-g"] = "toggle-search" },
				},
			},
			fzf_colors = {
				["fg"]      = { "fg", "Normal" },
				["bg"]      = { "bg", "Normal" },
				["fg+"]     = { "fg", "Normal" },
				["bg+"]     = { "bg", "CursorLine" },
				["hl"]      = { "fg", "Comment" },
				["hl+"]     = { "fg", "Statement" },
				["info"]    = { "fg", "PreProc" },
				["prompt"]  = { "fg", "Conditional" },
				["pointer"] = { "fg", "Exception" },
				["marker"]  = { "fg", "Keyword" },
				["spinner"] = { "fg", "Label" },
				["header"]  = { "fg", "Comment" },
			},
		}
	end,
	keys = {
		{
			"<Leader>f",
			function()
				require("fzf-lua").files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>rw",
			function()
				require("fzf-lua").grep_cword()
			end,
			desc = "Fzf Grep Current Word",
		},
		{
			"<Leader>rg",
			function()
				require("fzf-lua").grep()
			end,
			desc = "Find Files via grep",
		},
		{
			"<Leader>rq",
			function()
				require("fzf-lua").quickfix()
			end,
			desc = "Find Files via grep",
		},
		{
			"<Leader>rf",
			function()
				require("fzf-lua").resume()
			end,
			desc = "Resume an Fzf action",
		},
		{
			"<leader>gr",
			function()
				require("fzf-lua").lsp_references()
			end,
			desc = "Find Files",
		},
	},
}
