local local_path = vim.fn.expand "~/clones/own/h"

return {
	"https://codeberg.org/marcelmanz/highlighter.nvim.git",
	dir = vim.fn.isdirectory(local_path) == 1 and local_path or nil,
	config = function()
		require("highlighter").setup {
			highlights = {
				HighlighterDefault = "#FF8800",
				TextReview = "#00CCFF",
			},
		}
	end,
}
