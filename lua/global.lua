local function get_nvim_version()
	local nvim_version = vim.version()
	return string.format("  v%d.%d", nvim_version.minor, nvim_version.patch)
end

_G.get_nvim_version = get_nvim_version

-- Create function in global scope
local function typescript_server_import_all()
	if
		vim.bo.filetype == "typescript"
		or vim.bo.filetype == "typescriptreact"
	then
		vim.lsp.buf.code_action {
			apply = true,
			---@diagnostic disable-next-line: missing-fields
			context = {
				only = {
					---@diagnostic disable-next-line: assign-type-mismatch
					"source.addMissingImports.ts",
				},
			},
		}
	else
		vim.api.nvim_err_writeln "Not a typescript file"
		return
	end
end

_G.typescript_server_import_all = typescript_server_import_all


