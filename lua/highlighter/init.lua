local M = {}

local namespace_unique_id = vim.api.nvim_create_namespace "YellowHighlighter"

_G.__yellow_highlighter_op = function(motion_type)
	local bufnr = vim.api.nvim_get_current_buf()

	local start_mark = vim.api.nvim_buf_get_mark(bufnr, "[")
	local end_mark = vim.api.nvim_buf_get_mark(bufnr, "]")

	local start_row = start_mark[1] - 1
	local start_col = start_mark[2]
	local end_row = end_mark[1] - 1
	local end_col = end_mark[2]

	local lines = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)
	local line_len = lines[1] and string.len(lines[1]) or 0

	if motion_type == "line" then
		end_col = line_len
	else
		end_col = math.min(end_col + 1, line_len)
	end

	vim.api.nvim_buf_set_extmark(
		bufnr,
		namespace_unique_id,
		start_row,
		start_col,
		{
			end_row = end_row,
			end_col = end_col,
			hl_group = "CustomYellowHighlight",
		}
	)
end

function M.setup()
	vim.api.nvim_set_hl(
		0,
		"CustomYellowHighlight",
		{ bg = "#FDE047", fg = "#000000", bold = true }
	)

	vim.keymap.set("n", "gh", function()
		vim.go.operatorfunc = "v:lua.__yellow_highlighter_op"
		return "g@"
	end, { expr = true, desc = "Highlight using a motion (e.g., ghiw)" })

	vim.keymap.set("x", "gh", function()
		local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
		vim.api.nvim_feedkeys(esc, "x", false)

		vim.schedule(function()
			local bufnr = vim.api.nvim_get_current_buf()
			local start_pos = vim.api.nvim_buf_get_mark(bufnr, "<")
			local end_pos = vim.api.nvim_buf_get_mark(bufnr, ">")

			local start_row = start_pos[1] - 1
			local start_col = start_pos[2]
			local end_row = end_pos[1] - 1
			local end_col = end_pos[2] + 1

			local lines =
				vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)
			local line_len = lines[1] and string.len(lines[1]) or 0
			end_col = math.min(end_col, line_len)

			vim.api.nvim_buf_set_extmark(
				bufnr,
				namespace_unique_id,
				start_row,
				start_col,
				{
					end_row = end_row,
					end_col = end_col,
					hl_group = "CustomYellowHighlight",
				}
			)
		end)
	end, { desc = "Highlight visual selection" })

	vim.keymap.set("n", "gH", function()
		local bufnr = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_clear_namespace(bufnr, namespace_unique_id, 0, -1)
		vim.notify("Highlights cleared", vim.log.levels.INFO)
	end, { desc = "Clear all yellow highlights" })
end

return M
