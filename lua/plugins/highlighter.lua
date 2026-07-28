return {
	-- "marcelmanz/highlighter.nvim",
	dir = "~/clones/own/highlighter.nvim/",
	config = function()
		require("highlighter").setup {
			highlights = {
				HighlighterDefault = "#FF8800",
				TextReview = "#00CCFF",
			},
		}
	end,
}
