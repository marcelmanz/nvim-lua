local runner = require "lib.runner"

local function get_vitest_command()
	return "npm run test %"
end

local r = runner.create(get_vitest_command, { use_tmux = true })

vim.api.nvim_create_user_command("Vitest", function()
	r.run()
end, { desc = "Run vitest of current file in tmux window" })

vim.keymap.set("n", "<leader>vt", function()
	r.run()
end, {
	desc = "Run vitest of current file in tmux window",
	silent = true,
})

vim.keymap.set("n", "<leader>vtd", function()
	r.run_with_diff()
end, {
	desc = "Run vitest with diff in tmux window",
	silent = true,
})
