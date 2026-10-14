local M = {}

---@class IncDecMatch
---@field type '"date"' | '"version"'
---@field value string
---@field line integer
---@field col integer

local state = {
	index = 1,
	---@type IncDecMatch[]
	matches = {},
	ns = vim.api.nvim_create_namespace "incdec_highlight",
	---@type integer?
	hl_id = nil,
}

-- Adjust date ------------------------------------------------------------

local function adjust_date(date_str, part, delta)
	local y, m, d = date_str:match "(%d+)%-(%d+)%-(%d+)"
	if not (y and m and d) then
		return date_str
	end
	y, m, d = tonumber(y), tonumber(m), tonumber(d)
	if not y or not m or not d then
		return date_str
	end
	---@cast y integer
	---@cast m integer
	---@cast d integer

	local new_time
	if part == "year" then
		new_time = os.time { year = y + delta, month = m, day = d }
	elseif part == "month" then
		new_time = os.time { year = y, month = m + delta, day = d }
	else
		new_time = os.time { year = y, month = m, day = d + delta }
	end

	return os.date("%Y-%m-%d", new_time)
end

-- Adjust semver ----------------------------------------------------------

local function adjust_semver(ver, part, delta)
	local major, minor, patch = ver:match "(%d+)%.(%d+)%.(%d+)"
	if not (major and minor and patch) then
		return ver
	end
	major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)
	if not major or not minor or not patch then
		return ver
	end

	if part == "year" or part == "major" then
		major = math.max(0, major + delta)
	elseif part == "month" or part == "minor" then
		minor = math.max(0, minor + delta)
	else
		patch = math.max(0, patch + delta)
	end
	return string.format("%d.%d.%d", major, minor, patch)
end

-- Collect and sort matches ----------------------------------------------

---@return IncDecMatch[]
local function collect_matches()
	local matches = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for lnum, line in ipairs(lines) do
		for col, date in line:gmatch "()(%d%d%d%d%-%d%d%-%d%d)" do
			table.insert(
				matches,
				{ type = "date", value = date, line = lnum, col = col }
			)
		end
		for col, ver in line:gmatch "()(%d+%.%d+%.%d+)" do
			table.insert(
				matches,
				{ type = "version", value = ver, line = lnum, col = col }
			)
		end
	end

	table.sort(matches, function(a, b)
		if a.line == b.line then
			return a.col < b.col
		else
			return a.line < b.line
		end
	end)

	return matches
end

-- Jump navigation --------------------------------------------------------

function M.jump(next)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local cur_line, cur_col = cursor[1], cursor[2]
	state.matches = collect_matches()
	if #state.matches == 0 then
		return
	end

	-- clear previous highlight
	if state.hl_id then
		pcall(vim.api.nvim_buf_del_extmark, 0, state.ns, state.hl_id)
		state.hl_id = nil
	end

	-- find nearest index relative to current position
	local nearest = nil
	for i, match in ipairs(state.matches) do
		if next then
			if
				match.line > cur_line
				or (match.line == cur_line and match.col - 1 > cur_col)
			then
				nearest = i
				break
			end
		else
			if
				match.line < cur_line
				or (match.line == cur_line and match.col - 1 < cur_col)
			then
				nearest = i
			else
				break
			end
		end
	end

	-- wrap around if nothing found
	if not nearest then
		nearest = next and 1 or #state.matches
	end

	state.index = nearest
	local match = state.matches[state.index] --[[@as IncDecMatch]]
	vim.api.nvim_win_set_cursor(0, { match.line, match.col - 1 })

	-- highlight current match
	state.hl_id = vim.api.nvim_buf_set_extmark(
		0,
		state.ns,
		match.line - 1,
		match.col - 1,
		{
			end_col = match.col - 1 + #match.value,
			hl_group = "Visual",
			hl_mode = "combine",
		}
	)
end

-- Detect type ------------------------------------------------------------

function M.detect_type()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	for dstart, date in line:gmatch "()(%d%d%d%d%-%d%d%-%d%d)" do
		if col >= dstart - 1 and col < dstart - 1 + #date then
			return "date"
		end
	end
	for vstart, ver in line:gmatch "()(%d+%.%d+%.%d+)" do
		if col >= vstart - 1 and col < vstart - 1 + #ver then
			return "version"
		end
	end
	return nil
end

-- Replace target ---------------------------------------------------------

local function replace_in_line(line, old, new)
	local escaped = old:gsub("(%p)", "%%%1")
	return line:gsub(escaped, new, 1)
end

-- Adjust current match ---------------------------------------------------

function M.adjust(delta, part)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local lnum = cursor[1]
	local line = vim.api.nvim_get_current_line()

	local t = M.detect_type()
	if not t then
		return
	end

	local new_line
	if t == "date" then
		local old = line:match "%d%d%d%d%-%d%d%-%d%d"
		if not old then
			return
		end
		local new = adjust_date(old, part or "day", delta)
		new_line = replace_in_line(line, old, new)
	else
		local old = line:match "%d+%.%d+%.%d+"
		if not old then
			return
		end
		local new = adjust_semver(old, part or "patch", delta)
		new_line = replace_in_line(line, old, new)
	end

	vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { new_line })

	-- clear highlight after adjustment
	if state.hl_id then
		pcall(vim.api.nvim_buf_del_extmark, 0, state.ns, state.hl_id)
		state.hl_id = nil
	end
end

return M
