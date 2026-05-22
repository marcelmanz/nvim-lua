local function toggle_quickfix()
	local quickfix_open = false
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			quickfix_open = true
			break
		end
	end
	if quickfix_open then
		vim.cmd "cclose"
	else
		vim.cmd "botright copen"
	end
end

return toggle_quickfix
