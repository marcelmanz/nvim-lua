local tmux = require "lib.tmux"

vim.api.nvim_create_user_command("JustRun", function()
	tmux.create_tmux_persistent_command "just run"
end, { desc = "Run just run in tmux window" })

-- create just command that accept arguments
vim.api.nvim_create_user_command("Just", function(opts)
	if opts.args ~= "" then
		tmux.create_tmux_persistent_command("just " .. opts.args)
		return
	end
	tmux.create_tmux_persistent_command "just"
end, { desc = "Run just in tmux window", nargs = "?" })

vim.api.nvim_create_user_command("Rgr", function(opts)
	if opts.args ~= "" then
		tmux.create_tmux_persistent_command("rgr " .. opts.args)
		return
	end
	tmux.create_tmux_persistent_command "rgr"
end, { desc = "Search and replace with rgr", nargs = "?" })

vim.keymap.set("n", "<leader>jr", function()
	tmux.create_tmux_persistent_command "just run"
end, {
	desc = "Run just run in tmux window",
	silent = true,
})

vim.api.nvim_create_user_command("JustBuild", function()
	tmux.create_tmux_persistent_command "just build"
end, { desc = "Run just build in tmux window" })

vim.keymap.set("n", "<leader>jb", function()
	tmux.create_tmux_persistent_command "just build"
end, {
	desc = "Run just build in tmux window",
	silent = true,
})

vim.api.nvim_create_user_command("JustTest", function()
	tmux.create_tmux_persistent_command "just test"
end, { desc = "Run just test in tmux window" })

vim.keymap.set("n", "<leader>jt", function()
	tmux.create_tmux_persistent_command "just test"
end, {
	desc = "Run just test in tmux window",
	silent = true,
})
