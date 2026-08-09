local on_attach = require("lsp.on-attach").on_attach

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		on_attach(client, args.buf)
	end,
})

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
	"nix",
	"ruff",
	-- "basedpyright",
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

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		for _, client in ipairs(vim.lsp.get_clients()) do
			client:stop(true)
		end
	end,
})
