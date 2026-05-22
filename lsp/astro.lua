---@brief
---
--- https://github.com/withastro/language-tools/tree/main/packages/language-server
---
--- `astro-ls` can be installed via `npm`:
--- ```sh
--- npm install -g @astrojs/language-server
--- ```

local get_typescript_server_path =
	require("lib.typescript").get_typescript_server_path

---@type vim.lsp.Config
return {
	cmd = { "astro-ls", "--stdio" },
	filetypes = { "astro" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	init_options = {
		typescript = {},
	},
	before_init = function(_, config)
		if
			config.init_options
			and config.init_options.typescript
			and not config.init_options.typescript.tsdk
		then
			config.init_options.typescript.tsdk =
				get_typescript_server_path(config.root_dir)
		end
	end,
}
