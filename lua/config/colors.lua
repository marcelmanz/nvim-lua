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

--i vim: ts=2 sts=2 sw=2 et
