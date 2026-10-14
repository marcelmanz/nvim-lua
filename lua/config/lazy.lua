-- Bootstrap lazy.nvim
--    https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "tpope/vim-sleuth", event = "BufReadPost" },
	{ import = "plugins" },
}, {
	change_detection = {
		notify = false,
	},
	dev = {
		path = "~/clones/forks/",
	},
})

-- vim: ts=2 sts=2 sw=2 et
