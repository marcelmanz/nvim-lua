return {
	"folke/snacks.nvim",
	lazy = false,
	priority = 1000,
	opts = {
		picker = {
			enabled = true,
			format = "file",
			icons = { enabled = false },
			layout = {
				box = "minimal",
				backdrop = false,
				cycle = false,
				preview = true,
			},
			win = { style = "minimal" },
		},
		quickfile = { enabled = true },
		statuscolumn = { enabled = false },
		words = { enabled = false },
		bigfile = { enabled = true },
	},
	config = function(_, opts)
		local snacks = require "snacks"
		snacks.setup(opts)

		local function make_proc(cmd)
			return function()
				local res = vim.system({ "bash", "-lc", cmd }, { text = true })
					:wait()
				local out = res.stdout or ""
				local items = {}
				for line in out:gmatch "[^\r\n]+" do
					items[#items + 1] = { text = line, file = line }
				end
				return items
			end
		end

		local pickers = {
			changed_files = {
				title = "changed_files",
				finder = make_proc [[{ ~/scripts/git/default-git-diff.sh --name-only && git log --pretty=format: --name-only HEAD~2..HEAD; } | sort | uniq]],
			},
			conflicts = {
				title = "conflicts",
				finder = make_proc [[git diff --name-only --diff-filter=U --relative]],
			},
			staged_files = {
				title = "staged_files",
				finder = make_proc [[git diff --name-only --diff-filter=AM --cached --relative]],
			},
			untracked_files = {
				title = "untracked_files",
				finder = make_proc [[git ls-files --others --exclude-standard --exclude=.gitignore]],
			},
			non_staged_files = {
				title = "non_staged_files",
				finder = make_proc [[git diff --name-only --diff-filter=AM --relative]],
			},
			env_files = {
				title = "env_files",
				finder = make_proc [[find . -type f -name ".env*" | sort -V]],
			},
			zoxide_paths = {
				title = "zoxide_paths",
				finder = make_proc [[zoxide query -l]],
			},
		}

		local M = {}
		function M.open(name)
			local cfg = pickers[name]
			if not cfg then
				return
			end
			return snacks.picker {
				title = cfg.title,
				finder = cfg.finder,
			}
		end

		package.loaded["my.snacks_pick"] = nil
		package.preload["my.snacks_pick"] = function()
			return function(name)
				return M.open(name)
			end
		end

		vim.api.nvim_set_hl(0, "SnacksPickerNormal", { bg = "#000000" })
		vim.api.nvim_set_hl(
			0,
			"SnacksPickerBorder",
			{ bg = "#000000", fg = "#444444" }
		)
		vim.api.nvim_set_hl(
			0,
			"SnacksPickerTitle",
			{ bg = "#000000", fg = "#ffffff" }
		)
		vim.api.nvim_set_hl(
			0,
			"SnacksPickerInput",
			{ bg = "#000000", fg = "#ffffff" }
		)
		vim.api.nvim_set_hl(0, "SnacksPickerList", { bg = "#111111" })
		vim.api.nvim_set_hl(0, "SnacksPickerPreview", { bg = "#000000" })
	end,
	keys = {
		-- file operations
		-- {
		-- 	"<Leader>f",
		-- 	function()
		-- 		require("snacks").picker.files()
		-- 	end,
		-- 	desc = "Find Files",
		-- },
		{
			"<leader>do",
			function()
				require("snacks").picker.files { hidden = true }
			end,
			desc = "Find Hidden Files",
		},
		{
			"<leader>rc",
			function()
				require("snacks").picker.files { cwd = vim.fn.stdpath "config" }
			end,
			desc = "Config Files",
		},

		-- search and grep
		-- {
		-- 	"<leader>rg",
		-- 	function()
		-- 		vim.ui.input({ prompt = "Grep input > " }, function(query)
		-- 			if query and query ~= "" then
		-- 				require("snacks").picker.grep {
		-- 					search = query,
		-- 					title = "Grep (<c-g> to toggle live)",
		-- 				}
		-- 			end
		-- 		end)
		-- 	end,
		-- 	desc = "Live Grep",
		-- },
		-- {
		-- 	"<leader>re",
		-- 	function()
		-- 		require("snacks").picker.grep {
		-- 			title = "Grep (remember <c-g> to toggle live)",
		-- 		}
		-- 	end,
		-- 	desc = "Live Grep",
		-- },
		-- {
		-- 	"<leader>rw",
		-- 	function()
		-- 		require("snacks").picker.grep_word()
		-- 	end,
		-- 	desc = "Grep Current Word",
		-- },
		-- {
		-- 	"<leader>rq",
		-- 	function()
		-- 		vim.cmd.cclose()
		-- 		require("snacks").picker.qflist {
		-- 			live = true,
		-- 			title = "Quickfix",
		-- 		}
		-- 	end,
		-- 	desc = "Quickfix → Snacks picker",
		-- },
		{
			"<leader>br",
			function()
				require("snacks").picker.grep_buffers()
			end,
			desc = "Grep Buffers",
		},
		{
			"<leader>bu",
			function()
				require("snacks").picker.grep_buffers()
			end,
			desc = "Buffer Fuzzy Find",
		},

		-- buffers and navigation
		{
			"<leader>tb",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<Leader>km",
			function()
				require("snacks").picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>ht",
			function()
				require("snacks").picker.help()
			end,
			desc = "Help Tags",
		},

		-- LSP
		-- {
		-- 	"<Leader>gr",
		-- 	function()
		-- 		require("snacks").picker.lsp_references()
		-- 	end,
		-- 	desc = "LSP References",
		-- },
		-- {
		-- 	"<leader>sy",
		-- 	function()
		-- 		require("snacks").picker.lsp_symbols()
		-- 	end,
		-- 	desc = "Document Symbols",
		-- },

		-- git
		{
			"<Leader>gs",
			function()
				require("snacks").picker.git_status()
			end,
			desc = "Git Status",
		},
		{
			"<Leader>rb",
			function()
				require("snacks").picker.git_branches()
			end,
			desc = "Git Branches",
		},
		{
			"<leader>rr",
			function()
				require("snacks").picker.commands()
			end,
			desc = "Snacks Commands",
		},
		{
			"<leader>cf",
			function()
				require "my.snacks_pick" "changed_files"
			end,
			desc = "Changed Files (HEAD~2)",
		},
		{
			"<leader>mc",
			function()
				require "my.snacks_pick" "conflicts"
			end,
			desc = "Git Conflicts",
		},
		{
			"<leader>es",
			function()
				require "my.snacks_pick" "staged_files"
			end,
			desc = "Staged Files",
		},
		{
			"<leader>eu",
			function()
				require "my.snacks_pick" "untracked_files"
			end,
			desc = "Untracked Files",
		},
		{
			"<leader>en",
			function()
				require "my.snacks_pick" "non_staged_files"
			end,
			desc = "Non-staged Files",
		},
		{
			"<leader>ee",
			function()
				require "my.snacks_pick" "env_files"
			end,
			desc = ".env Files",
		},
		{
			"<leader>zo",
			function()
				local snacks = require "snacks"
				snacks.picker {
					title = "zoxide_paths",
					finder = function()
						local res = vim.system(
							{ "zoxide", "query", "-l" },
							{ text = true }
						):wait()
						local out = res.stdout or ""
						local items = {}
						for line in out:gmatch "[^\r\n]+" do
							items[#items + 1] = { text = line, file = line }
						end
						return items
					end,
					confirm = function(picker, item)
						local path = item.text
						if path then
							vim.cmd.vsplit()
							vim.cmd("lcd " .. vim.fn.fnameescape(path))
							require("oil").open()
						end
					end,
				}
			end,
			desc = "Zoxide Paths → Oil Split",
		},

		-- node modules (TODO: Migrate to snacks)
		-- {
		-- 	"<leader>nf",
		-- 	function()
		-- 		require("snacks").picker.grep {
		-- 			search = vim.fn.input "grep for > ",
		-- 			cwd = "./node_modules",
		-- 		}
		-- 	end,
		-- 	desc = "Node Modules Grep",
		-- },
		-- {
		-- 	"<leader>nm",
		-- 	function()
		-- 		require("snacks").picker.grep { cwd = "./node_modules" }
		-- 	end,
		-- 	desc = "Node Modules Live Grep",
		-- },
	},
}
