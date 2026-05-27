local function is_table_row(line)
	return line and line:match "|" ~= nil
end

local function is_separator_row(line)
	return line and line:match "|%s*:?%-+:?%s*|" ~= nil
end

local function get_header_line(start_row, fallback_line)
	local header_line = fallback_line
	for i = start_row, 1, -1 do
		local current_scan_line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
			or ""

		if not is_table_row(current_scan_line) then
			header_line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
				or ""
			break
		end

		if i == 1 then
			-- table is at the absolute top of the file
			header_line = current_scan_line
		end
	end

	return header_line
end

local function format_row_data(header_line, value_line)
	local headers = vim.split(header_line, "|")
	local values = vim.split(value_line, "|")
	local display_text = {}

	for i = 1, #headers do
		local h = vim.trim(headers[i] or "")
		local v = vim.trim(values[i] or "")

		-- clean up markdown bold/italics from header
		h = h:gsub("%*", ""):gsub("_", "")

		if h ~= "" then
			local display_val = v == "" and "*(empty)*" or v

			-- FIX: Insert as separate items to increase array size and window height
			table.insert(display_text, "**" .. h .. "**")
			table.insert(display_text, display_val)
			table.insert(display_text, "---")
		end
	end

	-- Remove the trailing separator line for a clean look
	if #display_text > 0 then
		table.remove(display_text, #display_text)
	end

	return display_text
end

local function hover_table_row()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]
	local line = vim.api.nvim_get_current_line()

	if not is_table_row(line) or is_separator_row(line) then
		vim.lsp.buf.hover()
		return
	end

	local header_line = get_header_line(row, line)
	local display_text = format_row_data(header_line, line)

	if #display_text == 0 then
		vim.lsp.buf.hover()
		return
	end

	table.insert(display_text, "")
	table.insert(display_text, "")
	table.insert(display_text, "")
	table.insert(display_text, "")

	vim.lsp.util.open_floating_preview(display_text, "markdown", {
		focus_id = "markdown_table_hover",
		wrap = true,
	})
end

vim.keymap.set(
	"n",
	"K",
	hover_table_row,
	{ buffer = true, desc = "Hover table row details" }
)
