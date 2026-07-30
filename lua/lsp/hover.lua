-- Floating preview override: convert markdown links to [n] footnote references
-- Also binds gx in every LSP float window to open URLs.

local refify_lines = require("lib.markdown-links").refify_lines

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	if not contents or vim.tbl_isempty(contents) then
		return
	end

	local references = refify_lines(contents)

	local merged_contents = {}
	local i = 1
	while i <= #contents do
		local current_line = contents[i]
		local next_line = contents[i + 1]
		if
			next_line
			and current_line:match "%[%d+%]$"
			and next_line:match "^%S"
		then
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
		if #line > max_width then
			max_width = #line
		end
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
	opts.border = "none"

	return orig_util_open_floating_preview(merged_contents, syntax, opts, ...)
end

-- Also bind gx in every float window to open URLs
local _orig_ofp_gx = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
	local bufnr, winid = _orig_ofp_gx(contents, syntax, opts, ...)
	if bufnr then
		vim.keymap.set("n", "gx", require("lib.open-url").open, {
			buffer = bufnr,
			silent = true,
			desc = "Open link in float",
		})
	end
	return bufnr, winid
end

-- vim: ts=2 sts=2 sw=2 et
