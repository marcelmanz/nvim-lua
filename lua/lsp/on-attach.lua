local M = {}

local on_attach = function(client, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("gra", function()
		require("fzf-lua").lsp_code_actions()
	end, "[C]ode [A]ction")

	nmap("gp", function()
		vim.cmd "vsplit"
		vim.lsp.buf.definition()
	end, "[G]oto Definition [S]plit")

	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")

	nmap(
		"<leader>gd",
		client.name == "denols" and vim.lsp.buf.definition
			or function()
				require("fzf-lua").lsp_definitions()
			end,
		"[G]oto [D]efinition"
	)
	nmap("<leader>d", function()
		require("fzf-lua").diagnostics()
	end, "Show [D] Diagnostics in qfl")
	nmap("grr", client.name == "denols" and vim.lsp.buf.references or function()
		require("fzf-lua").lsp_references()
	end, "[G]oto [R]eferences")
	nmap("gri", function()
		require("fzf-lua").lsp_implementations()
	end, "[G]oto [I]mplementation")
	nmap("<leader>D", function()
		require("fzf-lua").lsp_typedefs()
	end, "Type [D]efinition")
	nmap("<leader>ds", function()
		require("fzf-lua").lsp_document_symbols()
	end, "[D]ocument [S]ymbols")
	nmap("<leader>ws", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, "[W]orkspace [S]ymbols")

	-- K hover auto-set by nvim 0.12

	nmap(
		"<leader>z",
		vim.diagnostic.open_float,
		"Check current line for errors"
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

	nmap("gD", function()
		require("fzf-lua").lsp_declarations()
	end, "[G]oto [D]eclaration")

	client.server_capabilities.documentFormattingProvider = true
end

M.on_attach = on_attach

-- Load floating preview overrides (runs once at module load)
require "lsp.hover"

return M

-- vim: ts=2 sts=2 sw=2 et
