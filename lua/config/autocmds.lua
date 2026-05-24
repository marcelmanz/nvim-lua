local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

local yank_group = ag("YankHighlight", { clear = true })
local diff_hl_group = ag("MyDiffSigns", { clear = true })

-- Override diff highlights for readability
local diff_colors = {
	delete = "#681300",
	add = "#055800",
	change = "#105090",
	text_fg = "#000000",
}
au("ColorScheme", {
	group = diff_hl_group,
	pattern = "*",
	callback = function()
		vim.cmd "highlight SignColumn guibg=NONE ctermbg=NONE"
		vim.api.nvim_set_hl(
			0,
			"CustomDiffAdd",
			{ fg = diff_colors.text_fg, bg = diff_colors.add }
		)
		vim.api.nvim_set_hl(
			0,
			"CustomDiffChange",
			{ fg = diff_colors.text_fg, bg = diff_colors.change }
		)
		vim.api.nvim_set_hl(
			0,
			"CustomDiffDelete",
			{ fg = diff_colors.text_fg, bg = diff_colors.delete, bold = false }
		)
		vim.cmd [[highlight! link DiffAdd    CustomDiffAdd]]
		vim.cmd [[highlight! link DiffChange CustomDiffChange]]
		vim.cmd [[highlight! link DiffDelete CustomDiffDelete]]
	end,
})

local add_80_chars_on_markdown = ag("Add80CharsOnMarkdown", { clear = true })
local python_line_length = ag("PythonLineLength", { clear = true })
local relative_numbers_insert_mode =
	ag("RelativeNumbersInsertModes", { clear = true })

au(
	"InsertEnter",
	{ command = "set relativenumber", group = relative_numbers_insert_mode }
)
au(
	"InsertLeave",
	{ command = "set norelativenumber", group = relative_numbers_insert_mode }
)

au("TextYankPost", {
	command = "silent! lua vim.highlight.on_yank()",
	group = yank_group,
})

vim.filetype.add {
	extension = {
		typ = "typ",
		mdx = "mdx",
	},
	filename = {
		[".myclirc"] = "toml",
	},
	pattern = {
		["%.sh"] = "sh",
		["%.zsh"] = "sh",
		["%.bash"] = "sh",
		[".+bashrc"] = "sh",
		[".+zshrc"] = "sh",
		[".+_aliases"] = "sh",
		["%.env"] = "sh",
		["%.envrc"] = "sh",
		["%.env%..+"] = "sh",
		["sketchybarrc"] = "sh",
	},
}

-- Use BufReadPost so editorconfig has already set textwidth (via max_line_length)
-- before we sync colorcolumn to it. Falls back to 80 if nothing sets textwidth.
au({ "BufNewFile", "BufReadPost" }, {
	pattern = { "*.md" },
	callback = function()
		local tw = vim.bo.textwidth
		if tw == 0 then
			tw = 80
			vim.opt_local.textwidth = tw
		end
		vim.opt_local.colorcolumn = tostring(tw)
	end,
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

local open_url = require "lib.open-url"

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
	{ pattern = "*.*", command = "checktime", group = auto_reload_group }
)

-- vim: ts=2 sts=2 sw=2 et
