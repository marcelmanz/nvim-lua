if pcall(require, "blame") then
	vim.api.nvim_create_user_command("GitBlameClassic", function()
		pcall(vim.cmd "BlameToggle window")
	end, {})
end

-- create a command to toggle the quickfix window
vim.api.nvim_create_user_command(
	"TSImportAll",
	require("utils.typescript").typescript_server_import_all,
	{}
)

local function ConflictsQF()
	local out = vim.fn.systemlist "git grep -n -E '^<<<<<<< '"
	local qf = {}
	for _, l in ipairs(out) do
		local f, ln, text = l:match "([^:]+):(%d+):(.*)"
		if f and ln then
			table.insert(
				qf,
				{ filename = f, lnum = tonumber(ln), col = 1, text = text }
			)
		end
	end
	vim.fn.setqflist(qf, "r")
	local current_win = vim.api.nvim_get_current_win()
	if #qf > 0 then
		vim.cmd "cfirst"
	end
	vim.cmd "copen"
	if vim.api.nvim_win_is_valid(current_win) then
		vim.api.nvim_set_current_win(current_win)
	end
end

vim.keymap.set("n", "<leader>cq", ConflictsQF)

vim.api.nvim_create_user_command("ConflictsQF", ConflictsQF, {})

vim.api.nvim_create_user_command("ENV", function()
	-- Check if ./ENV directory exists
	if vim.fn.isdirectory "./ENV" == 0 then
		vim.notify("No ./ENV directory found", vim.log.levels.WARN)
		return
	end

	-- Use fzf-lua to show files in ./ENV directory
	require("fzf-lua").files {
		cwd = "./ENV",
	}
end, {})

-- Check ~/scripts/todos.sh and ~/scripts/find-todos.sh for more info
vim.api.nvim_create_user_command("Todo", function()
	-- If the Todo.md file exists in the current directory, open it
	local cwd = vim.fn.getcwd()
	local files = vim.fn.readdir(cwd)
	for _, file in ipairs(files) do
		if file:lower():match "^todo.*%.md$" then
			vim.cmd("vsplit " .. cwd .. "/" .. file)
			return
		end
	end

	-- if not, create a global todo file
	local date = os.date "%Y-%m-%d"
	local filename = string.format("~/notes/TODO:%s.md", date)
	vim.cmd("vsplit " .. filename)
end, {})

vim.api.nvim_create_user_command("CopyRelPath", function()
	local rel_path = vim.fn.expand "%:."
	if rel_path == "" then
		vim.notify("No file in current buffer", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", rel_path)
	vim.notify("Copied: " .. rel_path, vim.log.levels.INFO)
end, { desc = "Copy relative path of current buffer to clipboard" })

vim.api.nvim_create_user_command("UUIDGEN", function()
	local uuid = vim.fn.system("uuidgen"):gsub("\n", "")
	vim.api.nvim_put({ uuid }, "", true, true)
end, { desc = "Insert UUID at cursor" })

local print_conventional_commits_help = function()
	local buf = vim.api.nvim_create_buf(false, true)

	local text_lines = {
		"",
		" CONVENTIONAL COMMITS QUICK REFERENCE",
		"",
		" feat:     New feature for the user (not internal tooling)",
		" fix:      Bug fix for the user (not internal tooling)",
		" docs:     Documentation changes only",
		" style:    Formatting, missing semicolons, etc (no code change)",
		" refactor: Code restructuring without changing behavior",
		" perf:     Performance improvements",
		" test:     Adding/updating tests",
		" build:    Changes to build system or dependencies",
		" ci:       Changes to CI/CD configuration",
		" chore:    Other changes that don't modify src or test files",
		" revert:   Reverts a previous commit",
		"",
		" Format:   <type>[optional scope]: <description>",
		" Example:  feat(auth): add OAuth2 login support",
		"           fix: resolve memory leak in data processing",
		"",
		" Breaking: Add ! after type/scope for breaking changes",
		" Example:  feat!: remove deprecated API endpoints",
		"",
		" Scope:    Optional noun describing section of codebase",
		"           (e.g., api, parser, ui, database)",
		"",
	}

	vim.api.nvim_buf_set_lines(buf, 0, -1, true, text_lines)

	local max_width = 0
	for _, line in ipairs(text_lines) do
		max_width = math.max(max_width, #line)
	end

	local opts = {
		relative = "editor",
		width = max_width + 1,
		height = #text_lines,
		col = (vim.o.columns - max_width) / 2,
		row = (vim.o.lines - #text_lines) / 2,
		anchor = "NW",
		style = "minimal",
		border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
		title = "Conventional Commits",
		title_pos = "center",
	}

	vim.api.nvim_open_win(buf, true, opts)

	vim.keymap.set("n", "q", ":q<CR>", { buffer = buf })
	vim.keymap.set("n", "<Esc>", ":q<CR>", { buffer = buf })
end

vim.api.nvim_create_user_command(
	"ConventionalCommits",
	print_conventional_commits_help,
	{
		desc = "Show conventional commits quick reference",
	}
)

local mdwatch_job_id = nil

vim.api.nvim_create_user_command("MdWatch", function()
	if mdwatch_job_id then
		vim.fn.jobstop(mdwatch_job_id)
		mdwatch_job_id = nil
		vim.notify("mdwatch stopped", vim.log.levels.INFO)
	else
		local filepath = vim.fn.expand "%:p"
		if filepath == "" then
			vim.notify("No file to preview", vim.log.levels.WARN)
			return
		end
		mdwatch_job_id = vim.fn.jobstart({ "mdwatch", filepath }, {
			on_exit = function()
				mdwatch_job_id = nil
			end,
		})
		vim.notify("mdwatch started: " .. filepath, vim.log.levels.INFO)
		vim.notify "at http://127.0.0.1:3000/"
	end
end, { desc = "Toggle mdwatch markdown preview" })
