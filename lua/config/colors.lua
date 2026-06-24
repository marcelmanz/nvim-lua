vim.cmd.set "t_Co=256"

local preferred = {
	light = "minispring",
	dark = "github_dark_dimmed",
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
end

if vim.o.background == "light" then
	vim.cmd.colorscheme "minispring"
	vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#e8ece6" })
	vim.api.nvim_set_hl(0, "CursorLine", { bg = "#d5d9d3" })
	-- minispring uses yellow (#676900, dark olive) as Search bg — looks brown on light.
	-- Override with yellow_bg (#e6ed62, light yellow) which is the proper light-theme bg variant.
	vim.api.nvim_set_hl(0, "Search", { fg = "#2c2e33", bg = "#e6ed62" })
	vim.api.nvim_set_hl(0, "IncSearch", { fg = "#2c2e33", bg = "#e6ed62" })
	vim.api.nvim_set_hl(0, "CurSearch", { fg = "#2c2e33", bg = "#e6ed62" })
end

--i vim: ts=2 sts=2 sw=2 et
