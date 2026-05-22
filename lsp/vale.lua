---@brief
---
--- https://github.com/errata-ai/vale-ls
---
--- An implementation of the Language Server Protocol (LSP) for the Vale command-line tool.

---@type vim.lsp.Config
return {
	cmd = { "vale-ls" },
	filetypes = { "asciidoc", "markdown", "text", "tex", "rst", "html", "xml" },
	root_markers = { ".vale.ini" },

	on_init = function(client, _)
		local styles_path = vim.fn.expand "~/.vale/styles"
		local config_dir = styles_path .. "/config"
		local vocab_dir = config_dir .. "/vocabularies"
		local base_vocab_dir = vocab_dir .. "/Base"

		if vim.fn.isdirectory(styles_path) == 0 then
			vim.fn.mkdir(styles_path, "p")
		end

		if vim.fn.isdirectory(config_dir) == 0 then
			vim.fn.mkdir(config_dir, "p")
		end

		if vim.fn.isdirectory(vocab_dir) == 0 then
			vim.fn.mkdir(vocab_dir, "p")
		end

		if vim.fn.isdirectory(base_vocab_dir) == 0 then
			vim.fn.mkdir(base_vocab_dir, "p")
		end

		local styles_link = styles_path .. "/styles"
		local vale_data_dir = vim.fn.expand "~/.local/share/vale/styles"

		if
			vim.fn.isdirectory(vale_data_dir) == 1
			and vim.fn.isdirectory(styles_link) == 0
		then
			vim.fn.system { "ln", "-sf", vale_data_dir, styles_link }
		end

		vim.fn.system { "vale", "sync" }
	end,
}
