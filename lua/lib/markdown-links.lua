-- Convert inline markdown links and bare URLs to bottom reference links.
--
--   [text](url)   -> [text][N]
--   <url>         -> [linkN][N]
--   bare url      -> [linkN][N]
--
-- with a matching `[N]: url` block appended. Existing `[N]: url`
-- definitions and `[text][N]` references are preserved and reused so the
-- command is a no-op on files already in this shape (e.g. a notes TODO).

local M = {}

local URL = "https?://[%w_~/:.?#@!$&'*+,;=%%()%-]+"
local INLINE = "%[([^%]]*)%]%(([^%)]+)%)"
local AUTOLINK = "<(https?://[^>]+)>"
local FENCE = "^%s*```"
local REF_DEF = "^%s*%[(%d+)%]:%s*(%S+)"

-- trim trailing punctuation that's not part of the URL. Balanced parens
-- are kept (e.g. wikipedia ...Foo_(bar)); an unbalanced trailing `)` is
-- prose, so strip it. ponytail: cannot detect a leading `(` paired with a
-- stripped `)` without a real parser, so `(https://x)` -> `([link0][0`.
local function trim_url(url)
	url = url:gsub("[.,;:!?]+$", "")
	local opens = select(2, url:gsub("%(", ""))
	local closes = select(2, url:gsub("%)", ""))
	while closes > opens and url:sub(-1) == ")" do
		url = url:sub(1, -2)
		closes = closes - 1
	end
	return url
end

--- register a url, reusing an existing reference number when known
local function register(state, url)
	local n = state.url_to_n[url]
	if n then
		return n
	end
	n = state.next_n
	state.url_to_n[url] = n
	table.insert(state.refs, string.format("[%d]: %s", n, url))
	state.next_n = state.next_n + 1
	return n
end

local function transform_segment(seg, state)
	seg = seg:gsub(INLINE, function(text, url)
		return string.format("[%s][%d]", text, register(state, url))
	end)
	seg = seg:gsub(AUTOLINK, function(url)
		return string.format(
			"[link%d][%d]",
			register(state, url),
			register(state, url)
		)
	end)
	seg = seg:gsub(URL, function(url)
		url = trim_url(url)
		local n = register(state, url)
		return string.format("[link%d][%d]", n, n)
	end)
	return seg
end

-- transform a single line, skipping inline `code` spans
local function transform_line(line, state)
	local out, pos, in_code = {}, 1, false
	while pos <= #line do
		local bt = line:find("`", pos, true)
		local seg = bt and line:sub(pos, bt - 1) or line:sub(pos)
		table.insert(out, not in_code and transform_segment(seg, state) or seg)
		if bt then
			table.insert(out, "`")
			in_code = not in_code
			pos = bt + 1
		else
			break
		end
	end
	return table.concat(out)
end

--- transform body lines in place: ref-def lines are registered and left
--- untouched; fenced code blocks are skipped.
function M.transform_body(lines, state)
	local in_fence = false
	for i, line in ipairs(lines) do
		if line:match(FENCE) then
			in_fence = not in_fence
		elseif not in_fence then
			local n, url = line:match(REF_DEF)
			if n then
				state.url_to_n[url] = state.url_to_n[url] or tonumber(n)
			else
				lines[i] = transform_line(line, state)
			end
		end
	end
end

--- mutate `lines` into reference form and return the new `[n]: url` defs.
--- Used by the LSP hover override (fresh state, numbers from 0).
function M.refify_lines(lines)
	local state = { url_to_n = {}, refs = {}, next_n = 0 }
	M.transform_body(lines, state)
	return state.refs
end

local function split_existing_refs(lines)
	local i = #lines
	while i >= 1 and lines[i]:match(REF_DEF) do
		i = i - 1
	end
	while i >= 1 and lines[i] == "" do
		i = i - 1
	end
	local body, refs = {}, {}
	for k = 1, i do
		body[k] = lines[k]
	end
	for k = i + 1, #lines do
		if lines[k] ~= "" then
			table.insert(refs, lines[k])
		end
	end
	return body, refs
end

local function state_from_refs(refs)
	local state = { url_to_n = {}, refs = {}, next_n = 0 }
	local maxn = -1
	for _, l in ipairs(refs) do
		local n, url = l:match(REF_DEF)
		if n then
			n = tonumber(n)
			state.url_to_n[url] = n
			if n > maxn then
				maxn = n
			end
		end
	end
	state.next_n = maxn + 1
	return state
end

local function max_ref_in_body(body)
	local max = -1
	for _, l in ipairs(body) do
		for n in l:gmatch "%[(%d+)%]" do
			n = tonumber(n)
			if n > max then
				max = n
			end
		end
	end
	return max
end

--- format the whole buffer: reuse existing trailing `[n]: url` defs, convert
--- any remaining inline/bare links, append new defs after the existing ones.
function M.refify_buffer(bufnr)
	bufnr = bufnr or 0
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local body, refs = split_existing_refs(lines)
	local state = state_from_refs(refs)
	state.next_n = math.max(state.next_n, max_ref_in_body(body) + 1)
	M.transform_body(body, state)

	local out = {}
	vim.list_extend(out, body)
	if #refs > 0 or #state.refs > 0 then
		table.insert(out, "")
		vim.list_extend(out, refs)
		vim.list_extend(out, state.refs)
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out)
end

-- ponytail: self-check, run with `nvim -l lua/lib/markdown-links.lua`
function M._selfcheck()
	local function case(input, expect_refs, expect_body)
		local lines = vim.deepcopy(input)
		local refs = M.refify_lines(lines)
		assert(vim.deep_equal(refs, expect_refs), "refs: " .. vim.inspect(refs))
		assert(
			vim.deep_equal(lines, expect_body),
			"body: " .. vim.inspect(lines)
		)
	end

	case(
		{ "see [a](https://x.io) and [b](https://y.io)" },
		{ "[0]: https://x.io", "[1]: https://y.io" },
		{ "see [a][0] and [b][1]" }
	)
	case(
		{ "dup [a](https://x.io) then [b](https://x.io)" },
		{ "[0]: https://x.io" },
		{ "dup [a][0] then [b][0]" }
	)
	case(
		{ "bare https://x.io here." },
		{ "[0]: https://x.io" },
		{ "bare [link0][0] here." }
	)
	case(
		{ "autolink <https://x.io> end" },
		{ "[0]: https://x.io" },
		{ "autolink [link0][0] end" }
	)
	case({ "code `https://x.io` stays" }, {}, { "code `https://x.io` stays" })
	case(
		{ "```bash", "curl https://x.io", "```" },
		{},
		{ "```bash", "curl https://x.io", "```" }
	)
	-- percent-encoded url stays intact (the reported bug)
	case(
		{ "see https://x.io/steps/%7Babc%7D here" },
		{ "[0]: https://x.io/steps/%7Babc%7D" },
		{ "see [link0][0] here" }
	)
	-- balanced parens kept (wikipedia-style)
	case(
		{ "see https://en.wikipedia.org/wiki/Foo_(bar) end" },
		{ "[0]: https://en.wikipedia.org/wiki/Foo_(bar)" },
		{ "see [link0][0] end" }
	)
	-- sentence period after a paren'd url is stripped, parens kept
	case(
		{ "see https://en.wikipedia.org/wiki/Foo_(bar). end" },
		{ "[0]: https://en.wikipedia.org/wiki/Foo_(bar)" },
		{ "see [link0][0] end" }
	)

	-- buffer: reuse existing trailing refs, add new after
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"- [ ] Work on [#103879][0]",
		"",
		"[0]: https://x.io/entity",
		"and bare https://new.io",
	})
	-- note: trailing ref block is [0]:; "and bare..." is body (no trailing ref after it)
	-- rewrite so the ref block is truly trailing:
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"- [ ] Work on [#103879][0] and bare https://new.io",
		"",
		"[0]: https://x.io/entity",
	})
	M.refify_buffer(buf)
	local got = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	assert(got[1] == "- [ ] Work on [#103879][0] and bare [link1][1]", got[1])
	assert(got[2] == "", got[2])
	assert(got[3] == "[0]: https://x.io/entity", got[3])
	assert(got[4] == "[1]: https://new.io", got[4])
	vim.api.nvim_buf_delete(buf, { force = true })

	print "markdown-links selfcheck OK"
end

if arg and arg[0] and arg[0]:match "markdown%-links%.lua$" then
	M._selfcheck()
end

return M
