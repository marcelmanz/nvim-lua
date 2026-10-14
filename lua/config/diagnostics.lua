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
	update_in_insert = false,
	severity_sort = false,
	virtual_lines = false,
	virtual_text = {
		prefix = "●",
	},
	float = {
		source = true,
	},
}

-- vim: ts=2 sts=2 sw=2 et
