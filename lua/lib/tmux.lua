local M = {}

function M.inside_tmux_session()
	if vim.fn.exists "$TMUX" == 0 then
		return false
	end
	return true
end

function M.create_tmux_persistent_command(command)
	if not M.inside_tmux_session() then
		return false
	end

	local tmux_command = string.format("tmux new-window '%s; read'", command)

	vim.cmd("silent !" .. tmux_command)
	return true
end

function M.create_tmux_split_command(command)
	if not M.inside_tmux_session() then
		return false
	end
	local tmux_command = string.format("tmux split-window -h '%s'", command)
	vim.cmd("silent !" .. tmux_command)
	return true
end

function M.create_tmux_command(command)
	if not M.inside_tmux_session() then
		return false
	end

	local tmux_command = string.format("tmux new-window '%s'", command) -- bin: tmux

	vim.cmd("silent !" .. tmux_command)
	return true
end

return M
