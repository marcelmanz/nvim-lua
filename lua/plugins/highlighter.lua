local local_path = vim.fn.expand "~/clones/own/highlighter.nvim"

return {
	"marcelmanz/highlighter.nvim",
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
