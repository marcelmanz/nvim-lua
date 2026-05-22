local M = {}

local state = {
	marked_lines = nil,
	marked_bufnr = nil,
	marked_start = nil,
	marked_end = nil,
	mark_ns = vim.api.nvim_create_namespace "diff_mark",
	mark_id = nil,
	last_left_lines = nil,
	last_right_lines = nil,
}

local function get_visual_lines()
	local bufnr = vim.api.nvim_get_current_buf()
	local _, start_lnum, start_col, _ = unpack(vim.fn.getpos "'<")
	local _, end_lnum, end_col, _ = unpack(vim.fn.getpos "'>")

	if start_lnum > end_lnum then
		start_lnum, end_lnum = end_lnum, start_lnum
		start_col, end_col = end_col, start_col
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_lnum - 1, end_lnum, false)

	if #lines > 1 then
		lines[1] = lines[1]:sub(start_col)
		lines[#lines] = lines[#lines]:sub(1, end_col)
	else
		lines[1] = lines[1]:sub(start_col, end_col)
	end

	return bufnr, lines, start_lnum - 1, end_lnum - 1
end

local function get_split_direction()
	local layout = vim.fn.winlayout()
	local direction = layout[1]
	return direction == "row" and "split" or "vsplit"
end

local function create_temp_file(prefix, lines)
	local filename = string.format("/tmp/nvim-diff-%s-%d", prefix, os.time())
	vim.fn.writefile(lines, filename)
	return filename
end

function M.operator_mark()
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
		"n",
		false
	)

	if state.mark_id then
		pcall(
			vim.api.nvim_buf_del_extmark,
			state.marked_bufnr,
			state.mark_ns,
			state.mark_id
		)
	end

	local bufnr, lines, start_line, end_line = get_visual_lines()
	state.marked_lines = lines
	state.marked_bufnr = bufnr

	state.mark_id =
		vim.api.nvim_buf_set_extmark(bufnr, state.mark_ns, start_line, 0, {
			end_line = end_line + 1,
			hl_group = "DiffChange",
			hl_mode = "combine",
		})

	vim.notify(
		string.format("Selection marked as left side (%d lines)", #lines),
		vim.log.levels.INFO
	)
end

function M.operator_compare()
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
		"n",
		false
	)

	if not state.marked_lines then
		vim.notify(
			"No selection marked. Use `gdl` to mark a selection first.",
			vim.log.levels.WARN
		)
		return
	end

	local _, right_lines = get_visual_lines()
	state.last_left_lines = state.marked_lines
	state.last_right_lines = right_lines

	local left_file = create_temp_file("left", state.marked_lines)
	local right_file = create_temp_file("right", right_lines)

	local diff_cmd
	if vim.fn.executable "difft" == 1 then
		diff_cmd = string.format(
			"difft --display=inline --context=10000 %s %s; rm %s %s",
			left_file,
			right_file,
			left_file,
			right_file
		)
	else
		diff_cmd = string.format(
			"diff -u %s %s; rm %s %s",
			left_file,
			right_file,
			left_file,
			right_file
		)
	end

	local split_cmd = get_split_direction()
	vim.cmd(split_cmd)
	vim.cmd("terminal " .. diff_cmd)
	vim.cmd "startinsert"
end

function M.clear_mark()
	if state.mark_id then
		pcall(
			vim.api.nvim_buf_del_extmark,
			state.marked_bufnr,
			state.mark_ns,
			state.mark_id
		)
		state.mark_id = nil
	end
	state.marked_lines = nil
	state.marked_bufnr = nil
	vim.notify("Diff mark cleared", vim.log.levels.INFO)
end

function M.reopen_last_diff()
	if not state.last_left_lines or not state.last_right_lines then
		vim.notify("No previous diff to reopen.", vim.log.levels.WARN)
		return
	end

	local left_file = create_temp_file("left", state.last_left_lines)
	local right_file = create_temp_file("right", state.last_right_lines)

	local diff_cmd
	if vim.fn.executable "difft" == 1 then
		diff_cmd = string.format(
			"difft --display=inline --context=10000 %s %s; rm %s %s",
			left_file,
			right_file,
			left_file,
			right_file
		)
	else
		diff_cmd = string.format(
			"diff -u %s %s; rm %s %s",
			left_file,
			right_file,
			left_file,
			right_file
		)
	end

	local split_cmd = get_split_direction()
	vim.cmd(split_cmd)
	vim.cmd("terminal " .. diff_cmd)
	vim.cmd "startinsert"
end

vim.keymap.set("v", "gdl", function()
	vim.go.operatorfunc = "v:lua.require'features.diff'.operator_mark"
	vim.api.nvim_feedkeys("g@", "i", false)
end, { expr = false, silent = true })

vim.keymap.set("v", "gdc", function()
	vim.go.operatorfunc = "v:lua.require'features.diff'.operator_compare"
	vim.api.nvim_feedkeys("g@", "i", false)
end, { expr = false, silent = true })

vim.keymap.set("n", "gdr", M.reopen_last_diff, { desc = "Reopen last diff" })
vim.keymap.set("n", "gdx", M.clear_mark, { desc = "Clear diff mark" })

return M
