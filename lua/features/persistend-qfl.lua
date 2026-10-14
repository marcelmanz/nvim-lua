local M = {}
local qf_deleted_stack = {}

local DEFAULT_QF_PATH = vim.fn.stdpath "data" .. "/quickfix_list.txt"

M.DEFAULT_QF_PATH = DEFAULT_QF_PATH

function M.QfSave()
	local items = vim.fn.getqflist()
	if #items == 0 then
		return
	end
	local out = {}
	for _, it in ipairs(items) do
		out[#out + 1] = {
			filename = (it.bufnr and it.bufnr > 0)
					and vim.api.nvim_buf_get_name(it.bufnr)
				or it.filename,
			lnum = it.lnum,
			col = it.col,
			text = it.text,
			type = it.type,
		}
	end

	-- Use pcall to prevent errors from blocking exit
	local ok, encoded = pcall(vim.fn.json_encode, out)
	if ok then
		pcall(vim.fn.writefile, { encoded }, DEFAULT_QF_PATH)
	end
	return DEFAULT_QF_PATH
end

function M.QfLoad(opts)
	opts = opts or {}
	if vim.fn.filereadable(DEFAULT_QF_PATH) == 0 then
		return
	end

	local ok, lines = pcall(vim.fn.readfile, DEFAULT_QF_PATH)
	if not ok or not lines or #lines == 0 then
		return
	end

	local content = table.concat(lines --[[@as string[] ]], "\n")
	local ok2, decoded = pcall(vim.fn.json_decode, content)
	if not ok2 or type(decoded) ~= "table" or #decoded == 0 then
		return
	end

	-- Fix buffer references after session restore
	for _, item in ipairs(decoded) do
		if item.filename and item.filename ~= "" then
			-- Clear bufnr to force vim to resolve from filename
			item.bufnr = nil
		end
	end

	pcall(vim.fn.setqflist, {}, "r", { items = decoded })

	local has_args = vim.fn.argc() > 0
	local should_open = (opts.open ~= false) and not has_args
	if not should_open then
		return
	end

	local curwin = vim.api.nvim_get_current_win()
	local _qf_open = false
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			_qf_open = true
			break
		end
	end
	-- disabled for now
	-- if not _qf_open then
	-- 	pcall(vim.cmd, "botright copen")
	-- end
	pcall(vim.api.nvim_set_current_win, curwin)
end

function M.QfDeletePersistentFile()
	if vim.fn.filereadable(DEFAULT_QF_PATH) == 0 then
		return true
	end
	local delete_file_action_result = vim.fn.delete(DEFAULT_QF_PATH)

	if delete_file_action_result ~= 0 then
		vim.notify(
			"Failed to delete: "
				.. DEFAULT_QF_PATH
				.. " (rc="
				.. tostring(delete_file_action_result)
				.. ")",
			vim.log.levels.WARN
		)
		return false
	end
	return true
end

function M.QfDelCurrentEntry()
	if vim.bo.filetype ~= "qf" then
		return
	end
	local idx = vim.fn.line "."
	local qf = vim.fn.getqflist()
	if idx < 1 or idx > #qf then
		return
	end

	table.insert(qf_deleted_stack, { idx = idx, item = qf[idx] })
	table.remove(qf, idx)

	vim.fn.setqflist({}, "r", { items = qf })
	if #qf == 0 then
		vim.cmd.cclose()
	end
end

function M.QfUndoDeletedEntry()
	if #qf_deleted_stack == 0 then
		return
	end
	local last = table.remove(qf_deleted_stack) -- pop
	local qf = vim.fn.getqflist()
	table.insert(qf, last.idx, last.item) -- re-insert
	vim.fn.setqflist({}, "r", { items = qf })
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		M.QfLoad()
	end,
})

-- Save quickfix on exit (with timeout protection)
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		-- Wrapped in pcall to never block exit even on errors
		pcall(M.QfSave)
	end,
})

vim.api.nvim_create_user_command("QfDeletePersistentFile", function()
	M.QfDeletePersistentFile()
end, { nargs = "?" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.keymap.set("n", "dd", function()
			M.QfDelCurrentEntry()
		end, { buffer = true, desc = "Delete quickfix entry" })

		vim.keymap.set("n", "u", function()
			M.QfUndoDeletedEntry()
		end, { buffer = true, desc = "Undo quickfix delete" })
	end,
})

return M
