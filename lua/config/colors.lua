vim.cmd.set "t_Co=256"

local preferred = {
	light = "modus-operandi",
	dark = "alabaster",
}
local fallback = {
	light = "lunaperche",
	dark = "lighthouse",
}

local bg = vim.o.background
if not pcall(vim.cmd.colorscheme, preferred[bg]) then
	pcall(vim.cmd.colorscheme, fallback[bg])
end
vim.o.background = bg

vim.api.nvim_set_hl(0, "CursorLine", { underline = false })

if bg == "dark" then
	vim.cmd "hi VertSplit guifg=#373737 guibg=#373737gui=NONE cterm=NONE"
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#2d333b" })
	vim.api.nvim_set_hl(0, "FloatBorder", { link = "NormalFloat" })
	vim.api.nvim_set_hl(0, "RefIdentifier", { fg = "#50fa7b", bold = true })
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "markdown", "md" },
		callback = function()
			vim.fn.matchadd("RefNumberOnly", "\\v\\[\\zs\\d+\\ze\\]")
			vim.api.nvim_set_hl(
				0,
				"RefNumberOnly",
				{ fg = "#ff79c6", bold = false }
			)
		end,
	})
	vim.api.nvim_set_hl(
		0,
		"@ref.number.markdown_inline",
		{ fg = "#ff79c6", bold = true }
	)
	vim.api.nvim_set_hl(
		0,
		"@ref.number.markdown",
		{ fg = "#ff79c6", bold = false }
	)
else
	vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#e8ece6" })
	vim.api.nvim_set_hl(0, "CursorLine", { bg = "#f7f8f6" })

	-- Blend the mini.notify solid border into the body so it stops
	-- rendering as a fat grey band on modus-operandi
	vim.api.nvim_set_hl(0, "MiniNotifyBorder", { link = "MiniNotifyNormal" })
	vim.api.nvim_set_hl(0, "MiniClueNormal", { bg = "#ffffff" })
	vim.api.nvim_set_hl(0, "MiniClueBorder", { link = "MiniClueNormal" })
	vim.api.nvim_set_hl(
		0,
		"MiniClueNextKey",
		{ fg = "#0031a9", bg = "#ffffff", bold = true }
	)
	vim.api.nvim_set_hl(
		0,
		"MiniClueNextKeyWithPostkeys",
		{ fg = "#a60000", bg = "#ffffff", bold = true }
	)
	vim.api.nvim_set_hl(0, "MiniClueDescSingle", { link = "MiniClueNormal" })
	vim.api.nvim_set_hl(
		0,
		"MiniClueDescGroup",
		{ fg = "#884900", bg = "#ffffff" }
	)
	vim.api.nvim_set_hl(0, "FloatBorder", { link = "NormalFloat" })

	-- Override with search with yellow_bg (#e6ed62, light yellow) which is has more contrast
	vim.api.nvim_set_hl(0, "Search", { fg = "#2c2e33", bg = "#e6ed62" })
	vim.api.nvim_set_hl(0, "IncSearch", { fg = "#2c2e33", bg = "#e6ed62" })
	vim.api.nvim_set_hl(0, "CurSearch", { fg = "#2c2e33", bg = "#e6ed62" })
end

local transparent_flag_path = vim.fn.expand "$HOME/.cache/.theme_transparent"
vim.g.transparent = vim.uv.fs_stat(transparent_flag_path) ~= nil

local transparent_groups = {
	"Normal",
	"NormalNC",
	"SignColumn",
	"LineNr",
	"CursorLineNr",
	"FoldColumn",
	"EndOfBuffer",
	"StatusLine",
	"StatusLineNC",
	"TabLineFill",
	"WinSeparator",
	"VertSplit",
}

local function apply_transparency()
	if not vim.g.transparent then
		return
	end
	for _, group in ipairs(transparent_groups) do
		local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
		hl.bg = nil
		hl.ctermbg = nil
		vim.api.nvim_set_hl(0, group, hl)
	end
end

apply_transparency()

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("Transparency", { clear = true }),
	callback = apply_transparency,
})

vim.api.nvim_create_user_command("TransparentToggle", function()
	vim.g.transparent = not vim.g.transparent
	if vim.g.transparent then
		local flag_file = io.open(transparent_flag_path, "w")
		if flag_file then
			flag_file:close()
		end
	else
		os.remove(transparent_flag_path)
	end
	package.loaded["config.colors"] = nil
	require "config.colors"
end, {})

--i vim: ts=2 sts=2 sw=2 et
