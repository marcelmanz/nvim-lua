---@alias FzfKeyAction "accept" | "cancel" | "toggle-search" | "select-all" | "deselect-all" | "half-page-down" | "half-page-up"

---@class FzfLuaConfigDefaults
---@field keymap { fzf: table<string, FzfKeyAction> }

---@class FzfLuaConfig
---@field defaults FzfLuaConfigDefaults

---@class FzfLuaActions
---@field grep_lgrep function

---@class FzfLua
---@field setup fun(opts?: table)
---@field register_ui_select fun(opts?: table|function)
---@field files fun(opts?: table)
---@field grep_cword fun(opts?: table)
---@field grep fun(opts?: table)
---@field quickfix fun(opts?: table)
---@field resume fun(opts?: table)
---@field lsp_references fun(opts?: table)
---@field git_status fun(opts?: table)
---@field actions FzfLuaActions
---@field config FzfLuaConfig

return {
	"ibhagwan/fzf-lua",
	dependencies = { "echasnovski/mini.icons" },
	enabled = true,
	config = function()
		---@type FzfLua
		local fzf = require "fzf-lua"

		local actions = fzf.actions
		local config = fzf.config

		config.defaults.keymap.fzf["ctrl-q"] = "accept"
		config.defaults.keymap.fzf["ctrl-x"] = "cancel"

		fzf.setup {
			"borderless",
			files = {
				grep = {
					["ctrl-r"] = actions.grep_lgrep,
				},
			},
			keymap = {
				fzf = { ["ctrl-g"] = "toggle-search" },
			},
			fzf_colors = {
				["fg"] = { "fg", "Normal" },
				["bg"] = { "bg", "Normal" },
				["fg+"] = { "fg", "Normal" },
				["bg+"] = { "bg", "CursorLine" },
				["hl"] = { "fg", "Comment" },
				["hl+"] = { "fg", "Statement" },
				["info"] = { "fg", "PreProc" },
				["prompt"] = { "fg", "Conditional" },
				["pointer"] = { "fg", "Exception" },
				["marker"] = { "fg", "Keyword" },
				["spinner"] = { "fg", "Label" },
				["header"] = { "fg", "Comment" },
			},
		}

		-- fzf.register_ui_select() -- to register as visual.pick on nvim
	end,
	keys = {
		{
			"<Leader>f",
			function()
				---@type FzfLua
				local fzf = require "fzf-lua"
				fzf.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>rw",
			function()
				---@type FzfLua
				local fzf = require "fzf-lua"
				fzf.grep_cword()
			end,
			desc = "Fzf Grep Current Word",
		},
		{
			"<Leader>rg",
			function()
				---@type FzfLua
				local fzf = require "fzf-lua"
				fzf.grep()
			end,
			desc = "Find Files via grep",
		},
		{
			"<Leader>rq",
			function()
				---@type FzfLua
				local fzf = require "fzf-lua"
				fzf.quickfix()
			end,
			desc = "Find Quickfix",
		},
		{
			"<Leader>rf",
			function()
				---@type FzfLua
				local fzf = require "fzf-lua"
				fzf.resume()
			end,
			desc = "Resume an Fzf action",
		},
		{
			"<leader>gr",
			function()
				---@type FzfLua
				local fzf = require "fzf-lua"
				fzf.lsp_references()
			end,
			desc = "LSP References",
		},
		{
			"<leader>gi",
			function()
				---@type FzfLua
				local fzf = require "fzf-lua"
				fzf.git_status()
			end,
			desc = "Git Status",
		},
	},
}
