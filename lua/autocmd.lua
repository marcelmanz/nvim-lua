local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

-- GROUPS:
local yank_group = ag("YankHighlight", { clear = true })
local disable_node_modules_eslint_group =
	ag("DisableNodeModulesEslint", { clear = true })
local sh_filetype_group = ag("shFiletypeGroup", { clear = true })
local typ_filetype_group = ag("typFiletypeGroup", { clear = true })
local git_commit_auto_commands = ag("GitCommitAutoCommands", { clear = true })
local add_80_chars_on_markdown = ag("Add80CharsOnMarkdown", { clear = true })
local python_line_length = ag("PythonLineLength", { clear = true })
local disable_diagnostics_on_markdown =
	ag("DisableDiagnosticsOnMarkdown", { clear = true })
local relative_numbers_insert_mode =
	ag("RelativeNumbersInsertModes", { clear = true })

-- FUNCTIONS:

-- AUTO-COMMANDS:
au("InsertEnter", {
	command = "set relativenumber",
	group = relative_numbers_insert_mode,
})

au("InsertLeave", {
	command = "set norelativenumber",
	group = relative_numbers_insert_mode,
})

au("TextYankPost", {
	command = "silent! lua vim.highlight.on_yank()",
	group = yank_group,
})

-- au({ "BufNewFile", "BufRead" }, {
-- 	pattern = { "**/node_modules/**", "node_modules", "/node_modules/*" },
-- 	callback = function()
-- 		vim.diagnostic.disabled(true)
-- 	end,
-- 	group = disable_node_modules_eslint_group,
-- })

-- Format markdown links
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		local original_hover = vim.lsp.buf.hover

		-- Override the hover function
		vim.lsp.buf.hover = function()
			original_hover()

			-- 	vim.api.nvim_create_autocmd("BufEnter", {
			-- 		once = true,
			-- 		callback = function()
			-- 			local should_format = vim.bo.filetype == "markdown"
			-- 				and vim.bo.buftype == "nofile"
			--
			-- 			if should_format then
			-- 				vim.cmd.set "modifiable"
			-- 				vim.cmd "LinkConvertAll"
			-- 			end
			-- 		end,
			-- 	})
		end
	end,
})

au({ "BufNewFile", "BufRead" }, {
	pattern = {
		"*.sh",
		"*.zsh",
		"*.bash",
		"*bashrc",
		"*zshrc",
		"*_aliases",
		"*.env",
		"*.envrc",
		"*.env.*",
		"sketchybarrc",
	},
	command = "set filetype=sh",
	group = sh_filetype_group,
})

au({ "BufNewFile", "BufRead" }, {
	pattern = { "*.typ" },
	command = "set filetype=typ",
	group = typ_filetype_group,
})

local mdx_filetype_group = ag("mdxFiletypeGroup", { clear = true })
au({ "BufNewFile", "BufRead" }, {
	pattern = { "*.mdx" },
	command = "set filetype=mdx",
	group = mdx_filetype_group,
})

au({ "BufNewFile", "BufRead" }, {
	pattern = {
		"gitcommit",
		-- "*.diff",
	},
	callback = function()
		-- vim.cmd("colorscheme catppuccin")
	end,
	group = git_commit_auto_commands,
})

au({ "BufNewFile", "BufRead" }, {
	pattern = { "*.md" },
	command = "setlocal textwidth=80",
	group = add_80_chars_on_markdown,
})

au({ "BufNewFile", "BufRead" }, {
	pattern = { "*.py" },
	callback = function()
		vim.opt_local.textwidth = 100
		vim.opt_local.colorcolumn = "100"
	end,
	group = python_line_length,
})

--not mine
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = "NvimTree*",
	callback = function()
		local api = require "nvim-tree.api"
		local view = require "nvim-tree.view"

		if not view.is_visible() then
			api.tree.open()
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { ".myclirc" },
	command = "set filetype=toml",
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	pattern = { ".myclirc" },
	command = "set filetype=toml",
})

-- Remember cursor position when opening a file
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		vim.cmd 'silent! normal! g`"zv'
	end,
})

-- Instead of filetype use another group because copilot is not available yet
-- vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
-- 	pattern = "gitcommit",
-- 	callback = function()
-- 		vim.cmd.Copilot "attach"
-- 		vim.cmd.Copilot "enable"
-- 	end,
-- })

-- Display diagnostics as virtual text only if not in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	callback = function()
		vim.diagnostic.config { virtual_text = false }
	end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		vim.diagnostic.config { virtual_text = true, underline = true }
	end,
})

local open_url = require "open_url"

-- help / man docs opened by Shift-K (when no LSP hover exists)
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help", "man", "markdown" },
	callback = function(ev)
		vim.keymap.set(
			"n",
			"gx",
			open_url.open,
			{ buffer = ev.buf, desc = "Open URL under cursor (doc win)" }
		)
	end,
})

-- LSP hover pop-ups (Shift-K with LSP attached)
local orig_ofp = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
	local bufnr, winid = orig_ofp(contents, syntax, opts, ...)
	if bufnr then
		vim.keymap.set(
			"n",
			"gx",
			open_url.open,
			{ buffer = bufnr, silent = true, desc = "Open link in float" }
		)
	end
	return bufnr, winid
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "tutor",
	callback = function(ev)
		vim.keymap.set(
			"n",
			"gx",
			"<Cmd>call tutor#open_link()<CR>",
			{ buffer = ev.buf }
		)
	end,
})

-- Go to first line of file if filetype is gitcommit
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		vim.schedule(function()
			vim.cmd "1"
		end)
	end,
})

local auto_reload_group =
	vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd(
	{ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
	{
		pattern = "*.*",
		command = "checktime",
		group = auto_reload_group,
	}
)
