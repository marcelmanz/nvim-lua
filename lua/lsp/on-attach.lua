local M = {}

local on_attach = function(client, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	-- Native LSP defaults (0.11+): gra gri grn grr grt grx gO <C-S>
	-- Goto-def via tagfunc: <C-]> / <C-w>] (split) / <C-w>v<C-]> (vsplit)
	-- K hover auto-set by nvim 0.12

	local function hint(native)
		return function()
			vim.notify("use native: " .. native, vim.log.levels.WARN)
		end
	end

	-- Hints (native key exists)
	nmap("gp", hint "<C-w>v<C-]>", "Hint: vsplit + goto-def")
	nmap("gd", hint "<C-]>", "Hint: use <C-]>")
	nmap("<leader>gd", hint "<C-]>", "Hint: use <C-]>")
	nmap("<leader>D", hint "grt", "Hint: use grt")
	nmap("<leader>ds", hint "gO", "Hint: use gO")

	-- Custom g* (no native key)
	nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	nmap("gW", vim.lsp.buf.workspace_symbol, "[W]orkspace symbols")
	nmap("gl", vim.diagnostic.open_float, "Diagnostic float")
	if client:supports_method "textDocument/inlayHint" then
		local function toggle_inlay_hints()
			vim.lsp.inlay_hint.enable(
				not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr },
				{ bufnr = bufnr }
			)
		end
		nmap("grh", toggle_inlay_hints, "Toggle inlay [h]ints")
		vim.api.nvim_buf_create_user_command(
			bufnr,
			"ToggleInlayHints",
			toggle_inlay_hints,
			{ desc = "Toggle inlay hints" }
		)
	end

	-- Hints for retired <leader> bindings
	nmap("<leader>z", hint "gl", "Hint: use gl")
	nmap("<leader>ws", hint "gW", "Hint: use gW")
	nmap(
		"<leader>d",
		hint ":lua vim.diagnostic.setqflist()",
		"Hint: diagnostics qflist"
	)
	local function copy_diags(first, last, include_lines)
		vim.fn.setreg("+", {}, "V")
		local msgs = {}
		local filepath = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
		for l = first, last do
			for _, d in ipairs(vim.diagnostic.get(0, { lnum = l - 1 })) do
				local m = include_lines
						and (filepath .. ":" .. l .. ": " .. d.message)
					or (filepath .. ":" .. l .. ": " .. d.message)
				table.insert(msgs, m)
				vim.fn.setreg("+", vim.fn.getreg "+" .. m .. "\n", "V")
			end
		end
		if #msgs == 0 then
			return nil
		end
		return table.concat(msgs, "\n")
	end

	vim.keymap.set("n", "<leader>zy", function()
		local line = vim.api.nvim_win_get_cursor(0)[1]
		local txt = copy_diags(line, line)
		if not txt then
			vim.notify("No diagnostics on line " .. line, vim.log.levels.ERROR)
			return
		end
		vim.notify(
			"Diagnostics from line "
				.. line
				.. " copied to clipboard.\n\n"
				.. txt,
			vim.log.levels.INFO
		)
	end, { desc = "Copy current line errors" })

	vim.keymap.set("v", "<leader>zy", function()
		local mode = vim.fn.mode()
		local visual_active = mode:match "[vV\22]"
		local s = visual_active and vim.fn.line "v" or vim.fn.getpos("'<")[2]
		local e = visual_active and vim.fn.line "." or vim.fn.getpos("'>")[2]
		if s > e then
			s, e = e, s
		end
		local txt = copy_diags(s, e, true)
		if not txt then
			vim.notify("No diagnostics in selection", vim.log.levels.ERROR)
			return
		end
		vim.notify(
			"Diagnostics from lines "
				.. s
				.. "-"
				.. e
				.. " copied to clipboard.\n\n"
				.. txt,
			vim.log.levels.INFO
		)
	end, { desc = "Copy selected lines errors" })

	client.server_capabilities.documentFormattingProvider = true
end

M.on_attach = on_attach

-- Load floating preview overrides (runs once at module load)
require "lsp.hover"

return M

-- vim: ts=2 sts=2 sw=2 et
