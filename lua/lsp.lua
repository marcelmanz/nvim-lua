local on_attach = require("lsp-on-attach").on_attach

---@diagnostic disable-next-line: param-type-not-match
vim.lsp.config("*", { on_attach = on_attach })

local lsp_servers = {
	"astro",
	"bash",
	"c",
	"eslint",
	"fennel",
	"json",
	"lua",
	"markdown",
	-- "mdx",
	"md-oxide",
	"nix",
	"python",
	"qmlls",
	"rust",
	"toml",
	"typescript",
	"css",
	"tailwindcss",
	"elixir",
	-- "vale",
}

for _, lsp_name in ipairs(lsp_servers) do
	vim.lsp.enable(lsp_name)
end
