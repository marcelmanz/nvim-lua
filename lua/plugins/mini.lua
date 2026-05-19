local function setup_mini_notify(setup_notify)
	local notify_filter = function(notif_arr)
		local filter = function(notif)
			if
				notif.msg:match "^rust[_-]analyzer:?%s"
				or notif.msg:match "^null[_-]ls:?%s"
			then
				return notif.msg:match "Indexing "
			end
			return true
		end
		notif_arr = vim.tbl_filter(filter, notif_arr)
		---@diagnostic disable-next-line: undefined-global
		return MiniNotify.default_sort(notif_arr)
	end

	local opts = {
		content = {
			format = nil,
			sort = notify_filter,
		},
		lsp_progress = {
			enable = true,
			duration_last = 1000,
		},
		window = {
			config = {
				border = "solid",
			},
			max_width_share = 0.582,
			winblend = 25,
		},
	}

	local mini_notify = require "mini.notify"
	setup_notify(opts)
	vim.notify = mini_notify.make_notify()

	vim.api.nvim_create_user_command("Notifications", function()
		local notifications = MiniNotify.get_all()

		if #notifications == 0 then
			vim.notify "No notifications"
			return
		end

		for _, notif in ipairs(notifications) do
			print("[" .. notif.level .. "] " .. notif.msg)
		end
	end, {})
end

local function setup_mini_snippets(setup_snippets)
	local mini_snippets = require "mini.snippets"
	local gen_loader = mini_snippets.gen_loader

	local function share_snippets(file, langs)
		return function(ctx)
			if vim.tbl_contains(langs, ctx.lang) then
				return mini_snippets.read_file(file) or {}
			end
			return {}
		end
	end

	setup_snippets {
		snippets = {
			gen_loader.from_file "~/.config/nvim/snippets/global.json",
			gen_loader.from_lang(),
			share_snippets("~/.config/nvim/snippets/typescript.json", {
				"js",
				"jsx",
				"tsx",
				"javascript",
				"javascriptreact",
				"typescriptreact",
			}),
			share_snippets("~/.config/nvim/snippets/markdown.json", {
				"markdown",
				"mdx",
				"rmd",
			}),
		},
	}

	vim.api.nvim_create_autocmd("InsertLeave", {
		callback = function()
			local ok, ms = pcall(require, "mini.snippets")
			if ok and ms.session.get() then
				ms.session.stop()
			end
			if vim.snippet and vim.snippet.active and vim.snippet.active() then
				vim.snippet.stop()
			end
		end,
	})

	local ms_expand = function()
		MiniSnippets.expand { match = false }
	end
	vim.keymap.set("i", "<C-e>", ms_expand, { desc = "Expand all snippets" })
end

local function setup_mini_starter(setup_starter)
	local function get_plugins_count()
		local lazy = require "lazy"
		local plugins_count = lazy.plugins()
		return #plugins_count
	end

	local function is_git_ignored(file)
		local result = vim.fn.system(
			"git status --ignored --porcelain "
				.. vim.fn.shellescape(file)
				.. " 2>/dev/null"
		)

		if result:match "^!!" then
			return true
		end

		if file:match "/%.git/" or file:match "^%.git/" then
			return true
		end

		return false
	end

	local function custom_recent_files(n, current_dir, prefix_chars)
		return function()
			local recent_files = vim.v.oldfiles
			local items = {}
			local count = 0

			local sep = vim.loop.os_uname().sysname == "Windows_NT" and "\\"
				or "/"
			local cwd = vim.fn.getcwd()
			if cwd:sub(-#sep) ~= sep then
				cwd = cwd .. sep
			end

			for _, file in ipairs(recent_files) do
				if count >= n then
					break
				end

				local in_cwd = vim.startswith(file, cwd)
				local should_include = current_dir and in_cwd
					or not current_dir and not in_cwd

				if
					should_include
					and vim.fn.filereadable(file) == 1
					and not is_git_ignored(file)
				then
					count = count + 1
					local prefix = prefix_chars and prefix_chars[count] or ""
					table.insert(items, {
						name = prefix .. vim.fn.fnamemodify(file, ":~:."),
						action = "edit " .. file,
						section = current_dir and "Recent current dir"
							or "Recent global",
					})
				end
			end

			if #items == 0 then
				local section = current_dir and "Recent current dir"
					or "Recent global"
				return {
					{
						name = "No recent files",
						action = "",
						section = section,
					},
				}
			end

			return items
		end
	end

	local starter = require "mini.starter"

	local version = vim.version()

	local header = string.format(
		"running neovim v%s.%s.%s with %s plugins",
		version.major,
		version.minor,
		version.patch,
		get_plugins_count()
	)

	setup_starter {
		autoopen = true,
		evaluate_single = true,
		header = header,
		footer = "",
		query_updaters = [[abcdefghilmnopqrstuvwxyz0123456789_,.ABCDEFGHIJKLMNOPQRSTUVWXYZ]],
		items = {
			{
				name = "rc: vim config",
				action = "cd ~/.config/nvim/ | e init.lua",
				section = "Config",
			},
			{
				name = "sr: session reload",
				action = function()
					require "utils.toggle-qf"()
					vim.cmd "silent AutoSession restore"
				end,
				section = "Sessions",
			},
			{
				name = "ss: select session",
				action = "Autosession search",
				section = "Sessions",
			},
			{
				name = "fc: changed files",
				action = function()
					require("fzf-lua").git_status()
				end,
				section = "Files",
			},
			custom_recent_files(5, true, { "0: ", "1: ", "2: ", "3: ", "4: " }),
			custom_recent_files(
				5,
				false,
				{ "g0: ", "g1: ", "g2: ", "g3: ", "g4: " }
			),
			{ name = "q: quit nvim", action = "qa", section = "Actions" },
			{
				name = "e: new file",
				action = "ene | startinsert",
				section = "Actions",
			},
			{
				name = "lu: lazy update",
				action = "silent Lazy update",
				section = "Actions",
			},
			{
				name = "ls: lazy sync",
				action = "silent Lazy sync",
				section = "Actions",
			},
			{
				name = "lp: lazy profile",
				action = "silent Lazy profile",
				section = "Actions",
			},
			{
				name = "ff: find file",
				action = "lua require('fzf-lua').files()",
				section = "Files",
			},
			{
				name = "h: help tags",
				action = "lua require('fzf-lua').help_tags()",
				section = "Help",
			},
			{
				name = "fr: recent files",
				action = "lua require('fzf-lua').oldfiles()",
				section = "Files",
			},
		},
		content_hooks = {
			starter.gen_hook.adding_bullet(),
			starter.gen_hook.aligning("center", "center"),
		},
	}

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "ministarter",
		callback = function(ev)
			vim.keymap.set("n", "j", function()
				require("mini.starter").update_current_item "next"
			end, { buffer = ev.buf })
			vim.keymap.set("n", "k", function()
				require("mini.starter").update_current_item "prev"
			end, { buffer = ev.buf })
		end,
	})
end

local function setup_mini_statusline(setup_statusline)
	setup_statusline {
		content = {
			active = nil,
			inactive = nil,
		},
		use_icons = true,
		set_vim_settings = true,
	}
end

return {
	"echasnovski/mini.nvim",
	-- dir = vim.fn.expand "$HOME/clones/forks/mini.nvim",
	version = false,
	event = "VimEnter",
	dependencies = {
		{ "nvim-mini/mini.snippets", version = false },
	},
	config = function()
		setup_mini_notify(require("mini.notify").setup)
		setup_mini_snippets(require("mini.snippets").setup)
		setup_mini_starter(require("mini.starter").setup)
		setup_mini_statusline(require("mini.statusline").setup)

		-- mini.surround replaces nvim-surround (sa/sd/sr instead of ys/ds/cs)
		require("mini.surround").setup {
			mappings = {
				add            = "sa", -- Add surrounding in Normal and Visual modes
				delete         = "sd", -- Delete surrounding
				find           = "sf", -- Find surrounding (to the right)
				find_left      = "sF", -- Find surrounding (to the left)
				highlight      = "sh", -- Highlight surrounding
				replace        = "sr", -- Replace surrounding
				update_n_lines = "sn", -- Update `n_lines`
			},
		}

		if vim.o.background == "light" then
			vim.cmd.colorscheme "minispring"
			vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#e8ece6" })
			vim.api.nvim_set_hl(0, "CursorLine", { bg = "#d5d9d3" })
			-- minispring uses yellow (#676900, dark olive) as Search bg — looks brown on light.
			-- Override with yellow_bg (#e6ed62, light yellow) which is the proper light-theme bg variant.
			vim.api.nvim_set_hl(0, "Search",    { fg = "#2c2e33", bg = "#e6ed62" })
			vim.api.nvim_set_hl(0, "IncSearch", { fg = "#2c2e33", bg = "#e6ed62" })
			vim.api.nvim_set_hl(0, "CurSearch", { fg = "#2c2e33", bg = "#e6ed62" })
		end
	end,
	keys = {
		{ "<Leader>al", ":lua MiniStarter.open()<cr>", desc = "Starter menu" },
	},
}
