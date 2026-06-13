-- C / C++ debugging via codelldb (vscode-lldb adapter).
--
-- Requires the `codelldb` binary on PATH. Install options:
--   - nix:   nix profile install nixpkgs#vscode-extensions.vadimcn.vscode-lldb
--            (exposes the adapter as `codelldb`)
--   - mason: :MasonInstall codelldb
--   - manual: download from https://github.com/vadimcn/codelldb/releases

local function codelldb_command()
	local on_path = vim.fn.exepath "codelldb"
	if on_path ~= "" then
		return on_path
	end

	local mason_bin = vim.fn.stdpath "data" .. "/mason/bin/codelldb"
	if vim.fn.executable(mason_bin) == 1 then
		return mason_bin
	end

	return "codelldb"
end

local function pick_executable()
	return coroutine.create(function(coro)
		local path =
			vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		coroutine.resume(coro, (path == "" or path == nil) and nil or path)
	end)
end

local configurations = {
	{
		name = "Launch (codelldb)",
		type = "codelldb",
		request = "launch",
		program = pick_executable,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
	{
		name = "Attach to process (codelldb)",
		type = "codelldb",
		request = "attach",
		pid = function()
			return require("dap.utils").pick_process()
		end,
		cwd = "${workspaceFolder}",
	},
}

return {
	adapters = {
		codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = codelldb_command(),
				args = { "--port", "${port}" },
			},
		},
	},
	configurations = {
		c = configurations,
		cpp = configurations,
	},
}
