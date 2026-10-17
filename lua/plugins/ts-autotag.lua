return {
	"windwp/nvim-ts-autotag",
	ft = { "html", "tsx", "jsx", "xml", "vue", "svelte", "astro", "php" },
	config = function()
		---@diagnostic disable-next-line: undefined-field
		require("nvim-ts-autotag").setup {
			opts = {
				-- Defaults
				enable_close = true, -- Auto close tags
				enable_rename = true, -- Auto rename pairs of tags
				enable_close_on_slash = false, -- Auto close on trailing </
			},
			-- Also override individual filetype configs, these take priority.
			-- Empty by default, useful if one of the "opts" global settings
			-- doesn't work well in a specific filetype
			per_filetype = {
				-- ["html"] = { enable_close = false, },
				["markdown"] = {
					enable_close = false,
					enable_rename = false,
					enable_close_on_slash = false,
				},
			},
		}
	end,
}
