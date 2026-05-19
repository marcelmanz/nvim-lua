local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

local yank_group = ag("YankHighlight", { clear = true })
local git_commit_auto_commands = ag("GitCommitAutoCommands", { clear = true })
local add_80_chars_on_markdown = ag("Add80CharsOnMarkdown", { clear = true })
local python_line_length = ag("PythonLineLength", { clear = true })
local relative_numbers_insert_mode = ag("RelativeNumbersInsertModes", { clear = true })

au("InsertEnter", { command = "set relativenumber", group = relative_numbers_insert_mode })
au("InsertLeave", { command = "set norelativenumber", group = relative_numbers_insert_mode })

au("TextYankPost", {
	command = "silent! lua vim.highlight.on_yank()",
	group = yank_group,
})

vim.filetype.add({
	extension = {
		typ = "typ",
		mdx = "mdx",
	},
	filename = {
		[".myclirc"] = "toml",
	},
	pattern = {
		["%.sh"]         = "sh",
		["%.zsh"]        = "sh",
		["%.bash"]       = "sh",
		[".+bashrc"]     = "sh",
		[".+zshrc"]      = "sh",
		[".+_aliases"]   = "sh",
		["%.env"]        = "sh",
		["%.envrc"]      = "sh",
		["%.env%..+"]    = "sh",
		["sketchybarrc"] = "sh",
	},
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help", "man", "markdown" },
	callback = function(ev)
		vim.keymap.set("n", "gx", open_url.open, { buffer = ev.buf, desc = "Open URL under cursor (doc win)" })
	end,
})

local orig_ofp = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
	local bufnr, winid = orig_ofp(contents, syntax, opts, ...)
	if bufnr then
		vim.keymap.set("n", "gx", open_url.open, { buffer = bufnr, silent = true, desc = "Open link in float" })
	end
	return bufnr, winid
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "tutor",
	callback = function(ev)
		vim.keymap.set("n", "gx", "<Cmd>call tutor#open_link()<CR>", { buffer = ev.buf })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		vim.schedule(function() vim.cmd "1" end)
	end,
})

local auto_reload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd(
	{ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
	{ pattern = "*.*", command = "checktime", group = auto_reload_group }
)
