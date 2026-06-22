local tmux = require "lib.tmux"

vim.api.nvim_create_user_command("LazyGit", function()
	tmux.create_tmux_command "lazygit"
end, { desc = "Run git status in tmux window" })

vim.api.nvim_create_user_command("GitBlameLine", function()
	local filepath = vim.fn.expand "%:p"
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	tmux.create_tmux_command(
		"tig blame +" .. current_line .. " -- " .. filepath
	)
end, { desc = "Run tig blame on current line in tmux window" })

vim.keymap.set("n", "<leader>gb", "<cmd>GitBlameLine<cr>")

vim.api.nvim_create_user_command("GitBlameFile", function()
	local filepath = vim.fn.expand "%:p"
	tmux.create_tmux_command("git blame " .. filepath)
end, { desc = "Run git blame on current file in tmux window" })
