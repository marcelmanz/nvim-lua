local M = {}

local open_cmd = vim.ui and vim.ui.open
	or function(uri)
		vim.fn["netrw#BrowseX"](uri, 0)
	end

---@param s string
local function is_url(s)
	return s:match "^https?://" or s:match "^mailto:"
end

local function ref_from_pair(line, col)
	-- three captures: start-pos, id, end-pos
	for s1, id, e2 in line:gmatch "()%[[^%]]+%]%s*%[([^%]]+)%]()" do
		if col >= s1 and col <= e2 then
			return id
		end
	end
end

-- lone [id] reference
local function ref_from_single(line, col)
	for s, id, e in line:gmatch "()%[([^%]]+)%]()" do
		if col >= s and col <= e then
			return id
		end
	end
end

-- search forward first, then backward (no wrap until both fail)
local function goto_definition(id)
	local pat = ("\\v^\\s*\\[\\c%s\\]:"):format(vim.fn.escape(id, "\\"))
	return vim.fn.search(pat, "W") > 0 or vim.fn.search(pat, "bnW") > 0
end

function M.open()
	local line, col = vim.api.nvim_get_current_line(), vim.fn.col "."

	-- 1. bare URL / file under cursor
	local cfile = vim.fn.expand "<cfile>"
	if is_url(cfile) then
		return open_cmd(cfile)
	end

	-- 2. inline (https://…) link
	for s, parens, e in line:gmatch "()(%b())()" do
		if col >= s and col < e then
			local inside = parens:sub(2, -2)
			if is_url(inside) then
				return open_cmd(inside)
			end
		end
	end

	-- 3. reference links
	local save = vim.fn.getpos "." -- ①
	local ref = ref_from_pair(line, col) or ref_from_single(line, col)
	if ref and goto_definition(ref) then
		local url = vim.api.nvim_get_current_line():match "%]:%s*(%S+)"
		if url and is_url(url) then
			open_cmd(url)
			vim.fn.setpos(".", save) -- ②
			return
		end
	end

	vim.notify("No URL or reference under cursor", vim.log.levels.WARN)
end

function M.setup(lhs)
	vim.keymap.set(
		"n",
		lhs or "gx",
		M.open,
		{ desc = "Smart open of Markdown links/references" }
	)
end

return M
