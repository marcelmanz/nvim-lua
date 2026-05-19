vim.o.termguicolors = true
local theme_file = vim.fn.expand "$HOME/.cache/.theme_mode"
local theme_file = io.open(theme_file, "r")
if theme_file then
	vim.o.background = theme_file:read "*l" or "dark"
	theme_file:close()
else
	vim.o.background = "dark"
end
vim.cmd.set "t_Co=256"

vim.cmd "hi VertSplit guifg=#373737 guibg=#373737gui=NONE cterm=NONE"
