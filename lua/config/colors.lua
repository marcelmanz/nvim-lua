vim.cmd.set "t_Co=256"

local preferred = {
	light = "modus-operandi",
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
else
	vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#e8ece6" })
	vim.api.nvim_set_hl(0, "CursorLine", { bg = "#d5d9d3" })

	-- Blend the mini.notify solid border into the body so it stops
	-- rendering as a fat grey band on modus-operandi
	vim.api.nvim_set_hl(0, "MiniNotifyBorder", { link = "MiniNotifyNormal" })
	vim.api.nvim_set_hl(0, "MiniClueNormal", { bg = "#ffffff" })
	vim.api.nvim_set_hl(0, "MiniClueBorder", { link = "MiniClueNormal" })
	vim.api.nvim_set_hl(0, "MiniClueNextKey", { fg = "#0031a9", bg = "#ffffff", bold = true })
	vim.api.nvim_set_hl(0, "MiniClueNextKeyWithPostkeys", { fg = "#a60000", bg = "#ffffff", bold = true })
	vim.api.nvim_set_hl(0, "MiniClueDescSingle", { link = "MiniClueNormal" })
	vim.api.nvim_set_hl(0, "MiniClueDescGroup", { fg = "#884900", bg = "#ffffff" })
	vim.api.nvim_set_hl(0, "FloatBorder", { link = "NormalFloat" })

	-- Override with search with yellow_bg (#e6ed62, light yellow) which is has more contrast
	vim.api.nvim_set_hl(0, "Search", { fg = "#2c2e33", bg = "#e6ed62" })
	vim.api.nvim_set_hl(0, "IncSearch", { fg = "#2c2e33", bg = "#e6ed62" })
	vim.api.nvim_set_hl(0, "CurSearch", { fg = "#2c2e33", bg = "#e6ed62" })
end

--i vim: ts=2 sts=2 sw=2 et
