local M = {}

local on_attach = function(client, bufnr)
	local nmap = function(keys, func, desc)
		if desc then desc = "LSP: " .. desc end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("gra", function()
		require("fzf-lua").lsp_code_actions()
	end, "[C]ode [A]ction")

	nmap("gp", function()
		vim.cmd "vsplit"
		vim.lsp.buf.definition()
	end, "[G]oto Definition [S]plit")

	nmap(
		"gd",
		vim.lsp.buf.definition,
		"[G]oto [D]efinition"
	)

	nmap(
		"<leader>gd",
		client.name == "denols" and vim.lsp.buf.definition
			or function() require("fzf-lua").lsp_definitions() end,
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
	nmap(
		"<leader>wa",
		vim.lsp.buf.add_workspace_folder,
		"[W]orkspace [A]dd Folder"
	)
	nmap(
		"<leader>wr",
		vim.lsp.buf.remove_workspace_folder,
		"[W]orkspace [R]emove Folder"
	)
	nmap("<leader>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, "[W]orkspace [L]ist Folders")

	client.server_capabilities.documentFormattingProvider = true

	vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
		vim.lsp.buf.format {
			filter = function(client)
				return client.name ~= "lua_ls"
			end,
		}
	end, { desc = "Format current buffer with LSP" })
end

M.on_attach = on_attach

-- Runs once at module load, not per-buffer
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	if not contents or vim.tbl_isempty(contents) then
		return
	end

	local link_index = 0
	local references = {}
	local unique_refs = {}

	for i, line in ipairs(contents) do
		contents[i] = line:gsub("%[(.-)%]%((.-)%)", function(text, url)
			local ref
			if unique_refs[url] then
				ref = string.format("[%d]", unique_refs[url])
			else
				ref = string.format("[%d]", link_index)
				unique_refs[url] = link_index
				table.insert(references, string.format("[%d]: %s", link_index, url))
				link_index = link_index + 1
			end
			return string.format("[%s]%s", text, ref)
		end)
	end

	local merged_contents = {}
	local i = 1
	while i <= #contents do
		local current_line = contents[i]
		local next_line = contents[i + 1]
		if next_line and current_line:match "%[%d+%]$" and next_line:match "^%S" then
			current_line = current_line .. " " .. next_line
			i = i + 1
		end
		table.insert(merged_contents, current_line)
		i = i + 1
	end

	table.insert(merged_contents, "")
	for _, ref in ipairs(references) do
		table.insert(merged_contents, ref)
	end

	local max_width = 0
	for _, line in ipairs(merged_contents) do
		if #line > max_width then max_width = #line end
	end

	local total_lines = #merged_contents
	local number_of_references = #references
	local max_height = total_lines - number_of_references
	if number_of_references > 0 then
		max_height = max_height - 2
	end

	opts = opts or {}
	opts.max_width = max_width
	opts.max_height = max_height

	return orig_util_open_floating_preview(merged_contents, syntax, opts, ...)
end

return M
