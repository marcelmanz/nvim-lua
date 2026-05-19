vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused builtin plugins for faster startup
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_tutor = 1
vim.g.loaded_rplugin = 1
vim.g.loaded_shada_plugin = 1
vim.g.loaded_spellfile_plugin = 1

vim.o.winborder = "single"
vim.o.splitbelow = false
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.opt.guicursor = "i:hor20-Cursor/lCursor"
vim.api.nvim_set_hl(0, "CursorLine", { underline = false })

vim.opt.termguicolors = true
if vim.o.background ~= "light" then
	vim.cmd.colorscheme "lunaperche"
end

vim.g.ai_cmp = false

vim.o.expandtab = true
vim.o.smarttab = true
vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.cmdheight = 1
vim.o.mouse = "a"
vim.o.cursorline = true
vim.o.conceallevel = 0
vim.o.smartcase = true
vim.o.scrolloff = 8
vim.o.timeoutlen = 500
vim.o.updatetime = 300

vim.wo.wrap = false
vim.wo.nu = true
vim.wo.foldnestmax = 1
vim.wo.signcolumn = "yes"
vim.wo.colorcolumn = "80"

vim.opt.laststatus = 3
vim.cmd "set undolevels=10000"
vim.cmd "set undoreload=10000"
vim.opt.listchars = {
	tab = "∙ ",
	trail = "∙",
	eol = " ",
	extends = "❯",
}
vim.opt.list = true

vim.opt.undodir = os.getenv "HOME" .. "/.vim/undodir"
vim.opt.undofile = true
vim.o.autoread = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.opt.showcmd = false

vim.diagnostic.config {
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "e ",
			[vim.diagnostic.severity.WARN] = "w ",
			[vim.diagnostic.severity.HINT] = "h ",
			[vim.diagnostic.severity.INFO] = "i ",
		},
	},
	underline = false,
	undercurl = false,
	update_in_insert = false,
	severity_sort = false,
	virtual_lines = false,
	virtual_text = {
		prefix = "●",
	},
	float = {
		source = "always",
	},
}

-- vim: ts=2 sts=2 sw=2 et
