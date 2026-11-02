local toggle_script = vim.fn.expand "~/scripts/tmux/command-toggle.sh"
local toggle_option = "@toggle_claude_right"

local function tmux(args, stdin)
	local result = vim.system(
		vim.list_extend({ "tmux" }, args),
		{ text = true, stdin = stdin }
	):wait()
	return vim.trim(result.stdout or "")
end

local function find_claude_pane()
	local panes = tmux {
		"list-panes",
		"-a",
		"-F",
		"#{pane_id} #{" .. toggle_option .. "} #{window_id}",
	}
	for line in panes:gmatch "[^\n]+" do
		local pane_id, flag, window_id = line:match "^(%S+) (%S*) ?(%S*)$"
		if flag == "1" then
			return pane_id, window_id
		end
	end
end

local function send_message(pane_id, message)
	tmux({ "load-buffer", "-b", "nvim-claude", "-" }, message)
	tmux { "paste-buffer", "-p", "-d", "-b", "nvim-claude", "-t", pane_id }
	tmux { "send-keys", "-t", pane_id, "Enter" }
	tmux { "select-pane", "-t", pane_id }
end

local function send_to_claude(line1, line2)
	if not require("lib.tmux").inside_tmux_session() then
		vim.notify("Not inside tmux", vim.log.levels.WARN)
		return
	end

	local bufname = vim.api.nvim_buf_get_name(0)
	if bufname == "" then
		vim.notify("Buffer has no file", vim.log.levels.WARN)
		return
	end

	local ref = "@" .. vim.fn.fnamemodify(bufname, ":.") .. "#L" .. line1
	if line2 ~= line1 then
		ref = ref .. "-" .. line2
	end

	vim.ui.input({ prompt = "Claude: " }, function(input)
		if input == nil then
			return
		end

		local message = input == "" and ref or ref .. " " .. input
		local pane_id, window_id = find_claude_pane()

		if not pane_id then
			vim.system({ toggle_script, "claude", "right" }):wait()
			pane_id = find_claude_pane()
			if not pane_id then
				vim.notify("Could not start Claude pane", vim.log.levels.ERROR)
				return
			end
			vim.defer_fn(function()
				send_message(pane_id, message)
			end, 1500)
			return
		end

		local current_window = tmux {
			"display-message",
			"-p",
			"-t",
			vim.env.TMUX_PANE,
			"#{window_id}",
		}
		if window_id ~= current_window then
			vim.system({ toggle_script, "claude", "right" }):wait()
		end

		send_message(pane_id, message)
	end)
end

vim.api.nvim_create_user_command("Claude", function(opts)
	send_to_claude(opts.line1, opts.line2)
end, { range = true, desc = "Ask Claude about lines in the tmux toggle pane" })

vim.keymap.set("n", "<leader>a", function()
	local line = vim.fn.line "."
	send_to_claude(line, line)
end, { silent = true, desc = "Ask Claude about current line" })

vim.keymap.set("x", "<leader>a", function()
	local line1, line2 = vim.fn.line "v", vim.fn.line "."
	if line1 > line2 then
		line1, line2 = line2, line1
	end
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
		"n",
		false
	)
	send_to_claude(line1, line2)
end, { silent = true, desc = "Ask Claude about selection" })
