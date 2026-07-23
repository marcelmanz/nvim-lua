local M = {}

local namespace_unique_id = vim.api.nvim_create_namespace "YellowHighlighter"
local db_path = vim.fn.stdpath "data" .. "/highlighter_marks.json"

local function load_db()
	local f = io.open(db_path, "r")
	if not f then
		return {}
	end
	local content = f:read "*a"
	f:close()
	if content == "" then
		return {}
	end
	local ok, data = pcall(vim.fn.json_decode, content)
	return ok and data or {}
end

local function save_db(db)
	local f = io.open(db_path, "w")
	if f then
		f:write(vim.fn.json_encode(db))
		f:close()
	end
end

local function load_buffer_marks(bufnr)
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	if filepath == "" then
		return
	end

	local db = load_db()
	local marks = db[filepath] or {}

	vim.api.nvim_buf_clear_namespace(bufnr, namespace_unique_id, 0, -1)
	for _, pos in ipairs(marks) do
		pcall(
			vim.api.nvim_buf_set_extmark,
			bufnr,
			namespace_unique_id,
			pos[1],
			pos[2],
			{
				end_row = pos[3],
				end_col = pos[4],
				hl_group = "CustomYellowHighlight",
			}
		)
	end
end

local function save_buffer_marks(bufnr)
	local filepath = vim.api.nvim_buf_get_name(bufnr)
	if filepath == "" then
		return
	end

	local db = load_db()

	-- get all marks in this buffer
	local marks = vim.api.nvim_buf_get_extmarks(
		bufnr,
		namespace_unique_id,
		0,
		-1,
		{ details = true }
	)

	if #marks == 0 then
		db[filepath] = nil
	else
		db[filepath] = {}
		for _, mark in ipairs(marks) do
			local details = mark[4]

			if details then
				table.insert(db[filepath], {
					mark[2], -- start_row
					mark[3], -- start_col
					details.end_row,
					details.end_col,
				})
			end
		end
	end
	save_db(db)
end

local function toggle_highlight(bufnr, start_row, start_col, end_row, end_col)
	local existing_marks = vim.api.nvim_buf_get_extmarks(
		bufnr,
		namespace_unique_id,
		{ start_row, start_col },
		{ end_row, end_col },
		{ overlap = true }
	)

	if #existing_marks > 0 then
		-- toggle off: remove existing overlapping marks
		for _, mark in ipairs(existing_marks) do
			vim.api.nvim_buf_del_extmark(bufnr, namespace_unique_id, mark[1])
		end
	else
		-- toggle on: create the new mark
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

	save_buffer_marks(bufnr)
end

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

	toggle_highlight(bufnr, start_row, start_col, end_row, end_col)
end

function M.setup()
	vim.api.nvim_set_hl(
		0,
		"CustomYellowHighlight",
		{ bg = "#FDE047", fg = "#000000", bold = true }
	)

	local augroup =
		vim.api.nvim_create_augroup("YellowHighlighterAuto", { clear = true })

	vim.api.nvim_create_autocmd({ "BufReadPost" }, {
		group = augroup,
		callback = function(args)
			load_buffer_marks(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = augroup,
		callback = function(args)
			save_buffer_marks(args.buf)
		end,
	})

	vim.keymap.set("n", "gh", function()
		vim.go.operatorfunc = "v:lua.__yellow_highlighter_op"
		return "g@"
	end, { expr = true, desc = "Toggle highlight using a motion (e.g., ghiw)" })

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

			toggle_highlight(bufnr, start_row, start_col, end_row, end_col)
		end)
	end, { desc = "Toggle visual highlight" })

	vim.keymap.set("n", "gH", function()
		local bufnr = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_clear_namespace(bufnr, namespace_unique_id, 0, -1)
		save_buffer_marks(bufnr)
		vim.notify("Highlights cleared", vim.log.levels.INFO)
	end, { desc = "Clear all yellow highlights" })
end

return M
