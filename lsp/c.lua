---@brief
---
--- https://clangd.llvm.org/installation.html
---
--- - **NOTE:** Clang >= 11 is recommended! See [#23](https://github.com/neovim/nvim-lspconfig/issues/23).
--- - If `compile_commands.json` lives in a build directory, you should
---   symlink it to the root of your source tree.
---   ```
---   ln -s /path/to/myproject/build/compile_commands.json /path/to/myproject/
---   ```
--- - clangd relies on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
---   specified as compile_commands.json, see https://clangd.llvm.org/installation#compile_commandsjson

-- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
local function switch_source_header(bufnr, client)
	local method_name = "textDocument/switchSourceHeader"
	---@diagnostic disable-next-line:param-type-mismatch
	if not client or not client:supports_method(method_name) then
		return vim.notify(
			("method %s is not supported by any servers active on the current buffer"):format(
				method_name
			)
		)
	end
	local params = vim.lsp.util.make_text_document_params(bufnr)
	---@diagnostic disable-next-line:param-type-mismatch
	client:request(method_name, params, function(err, result)
		if err then
			error(tostring(err))
		end
		if not result then
			vim.notify "corresponding file cannot be determined"
			return
		end
		vim.cmd.edit(vim.uri_to_fname(result))
	end, bufnr)
end

local function symbol_info(bufnr, client)
	local method_name = "textDocument/symbolInfo"
	---@diagnostic disable-next-line:param-type-mismatch
	if not client or not client:supports_method(method_name) then
		return vim.notify("Clangd client not found", vim.log.levels.ERROR)
	end
	local win = vim.api.nvim_get_current_win()
	local params =
		vim.lsp.util.make_position_params(win, client.offset_encoding)
	---@diagnostic disable-next-line:param-type-mismatch
	client:request(method_name, params, function(err, res)
		if err or #res == 0 then
			-- Clangd always returns an error, there is no reason to parse it
			return
		end
		local container = string.format("container: %s", res[1].containerName) ---@type string
		local name = string.format("name: %s", res[1].name) ---@type string
		vim.lsp.util.open_floating_preview({ name, container }, "", {
			height = 2,
			width = math.max(string.len(name), string.len(container)),
			focusable = false,
			focus = false,
			title = "Symbol Info",
		})
	end, bufnr)
end

---@class ClangdInitializeResult: lsp.InitializeResult
---@field offsetEncoding? string

local function build_cmd()
	local seen, drivers = {}, {}
	for _, name in ipairs({ "g++", "gcc", "c++", "cc", "clang++", "clang" }) do
		local p = vim.fn.exepath(name)
		if p ~= "" then
			local real = vim.fn.resolve(p)
			local key = real ~= "" and real or p
			if not seen[key] then
				seen[key] = true
				table.insert(drivers, key)
			end
		end
	end
	local cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--header-insertion=iwyu",
		"--function-arg-placeholders",
		"--pch-storage=memory",
	}
	if #drivers > 0 then
		table.insert(cmd, "--query-driver=" .. table.concat(drivers, ","))
	end
	return cmd
end

---@type vim.lsp.Config
return {
	cmd = build_cmd(),
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac", -- AutoTools
		".git",
	},
	capabilities = {
		textDocument = {
			completion = {
				editsNearCursor = true,
			},
		},
		offsetEncoding = { "utf-8", "utf-16" },
	},
	---@param init_result ClangdInitializeResult
	on_init = function(client, init_result)
		if init_result.offsetEncoding then
			client.offset_encoding = init_result.offsetEncoding
		end
	end,
	on_attach = function(client, bufnr)
		vim.api.nvim_buf_create_user_command(
			bufnr,
			"LspClangdSwitchSourceHeader",
			function()
				switch_source_header(bufnr, client)
			end,
			{ desc = "Switch between source/header" }
		)

		vim.api.nvim_buf_create_user_command(
			bufnr,
			"LspClangdShowSymbolInfo",
			function()
				symbol_info(bufnr, client)
			end,
			{ desc = "Show symbol info" }
		)

		vim.keymap.set("n", "grs", function()
			switch_source_header(bufnr, client)
		end, {
			buffer = bufnr,
			desc = "LSP: Switch [s]ource/header (jump .cpp <-> .h/.hpp)",
		})

		vim.keymap.set("n", "grth", function()
			vim.lsp.buf.typehierarchy "subtypes"
		end, {
			buffer = bufnr,
			desc = "LSP: [T]ype [h]ierarchy subtypes (classes deriving FROM this)",
		})
		vim.keymap.set("n", "grtH", function()
			vim.lsp.buf.typehierarchy "supertypes"
		end, {
			buffer = bufnr,
			desc = "LSP: [T]ype [H]ierarchy supertypes (base classes this inherits FROM)",
		})
		vim.keymap.set("n", "grc", vim.lsp.buf.incoming_calls, {
			buffer = bufnr,
			desc = "LSP: Incoming [c]alls (who calls this function)",
		})
		vim.keymap.set("n", "grC", vim.lsp.buf.outgoing_calls, {
			buffer = bufnr,
			desc = "LSP: Outgoing [C]alls (functions this one calls)",
		})
	end,
}
