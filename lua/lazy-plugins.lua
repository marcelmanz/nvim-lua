-- [[ Configure plugins ]]
require("lazy").setup({
	{ "tpope/vim-sleuth", event = "BufReadPost" }, -- Detect tabstop and shiftwidth automatically

	-- Dynamic plugin loading based on profile
	unpack(require("plugin-profiles").get_imports()),
}, {
	change_detection = {
		notify = false,
	},
	dev = {
		path = "~/clones/forks/",
	},
})

-- vim: ts=2 sts=2 sw=2 et
