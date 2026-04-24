---@brief
--- https://github.com/mdx-js/mdx-analyzer
---
--- `mdx-analyzer`, a language server for MDX
---
--- NOTE: Requires TypeScript installed in node_modules.
--- For Deno projects, run: npm install -D typescript

local get_typescript_server_path =
	require("utils.typescript").get_typescript_server_path

---@type vim.lsp.Config
return {
	cmd = { "mdx-language-server", "--stdio" },
	filetypes = { "mdx" },
	root_markers = { "package.json", "deno.json", "deno.jsonc" },
	settings = {},
	init_options = {
		typescript = {},
	},
	before_init = function(_, config)
		local tsdk = get_typescript_server_path(config.root_dir)
		if tsdk == "" then
			local is_deno = vim.fs.find(
				{ "deno.json", "deno.jsonc" },
				{ path = config.root_dir, upward = true }
			)[1]
			local hint = is_deno
					and "Deno project detected. Install TypeScript: npm install -D typescript"
				or "TypeScript not found. LSP requires: npm install -D typescript"
			vim.notify("MDX LSP: " .. hint, vim.log.levels.WARN)
			return false
		end
		config.init_options.typescript.tsdk = tsdk
	end,
}
