local local_path = vim.fn.expand "~/clones/own/highlighter.nvim/"

return {
	"https://codeberg.org/marcelmanz/highlighter.nvim.git",
	-- dir = vim.fn.isdirectory(local_path) == 1 and local_path or nil,
	config = function()
		require("highlighter").setup {
			fuzzy_default = false,
			highlights = {
				TextReview = "Visual"
			},
		}
	end,
}
