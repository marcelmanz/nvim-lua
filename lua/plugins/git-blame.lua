return {
	"f-person/git-blame.nvim",
	dependencies = {
		{
			"linrongbin16/gitlinker.nvim",
			config = function()
				require("gitlinker").setup()
			end,
		},
	},
	cmd = {
		"GitBlameToggle",
		"GitBlameEnable",
		"GitBlameOpenCommitURL",
		"GitBlameOpenFileURL",
		"GitBlameCopySHA",
		"GitBlameCopyFileURL",
	},
	keys = {
		{
			"<Leader>go",
			"<cmd>GitBlameOpenFileURL<cr>",
			desc = "Open file URL in git blame",
		},
		{
			"<Leader>yl",
			function()
				require("gitlinker").link()
			end,
			desc = "Copy file URL with current branch",
		},
		{
			"<Leader>yc",
			function()
				local original_cwd = vim.fn.getcwd()
				local file = vim.fn.expand "%:p"
				local file_dir = vim.fn.fnamemodify(file, ":h")
				local line_num = vim.fn.line "."
				local line_content = vim.fn.getline "."

				vim.cmd("cd " .. vim.fn.fnameescape(file_dir))

				local git_root =
					vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 then
					vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
					vim.notify(
						"File is not in a git repository",
						vim.log.levels.WARN
					)
					return
				end

				vim.cmd("cd " .. vim.fn.fnameescape(git_root))
				local relative_file = vim.fn.fnamemodify(file, ":.")

				local blame = vim.fn.systemlist(
					string.format(
						"git blame -L %d,%d --porcelain %s",
						line_num,
						line_num,
						relative_file
					)
				)

				vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))

				if vim.v.shell_error ~= 0 then
					vim.notify("Failed to get git blame", vim.log.levels.WARN)
					return
				end

				local commit_hash = blame[1]:match "^(%w+)"
				local author, date, summary

				for _, line in ipairs(blame) do
					if line:match "^author " then
						author = line:match "^author (.+)"
					elseif line:match "^author%-time " then
						local timestamp =
							tonumber(line:match "^author%-time (%d+)")
						date = os.date("%Y-%m-%d", timestamp)
					elseif line:match "^summary " then
						summary = line:match "^summary (.+)"
					end
				end

				local result = string.format(
					"(%s) %s:%d: %s",
					commit_hash:sub(1, 8),
					relative_file,
					line_num,
					line_content
				)

				vim.fn.setreg("+", result)
				vim.notify(
					"Copied blame info with line content",
					vim.log.levels.INFO
				)
			end,
			desc = "Copy git blame with line content",
		},
		{
			"<Leader>gs",
			function()
				local original_cwd = vim.fn.getcwd()
				local file = vim.fn.expand "%:p"
				local file_dir = vim.fn.fnamemodify(file, ":h")
				local line_num = vim.fn.line "."

				vim.cmd("cd " .. vim.fn.fnameescape(file_dir))

				local git_root =
					vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 then
					vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
					vim.notify(
						"File is not in a git repository",
						vim.log.levels.WARN
					)
					return
				end

				vim.cmd("cd " .. vim.fn.fnameescape(git_root))
				local relative_file = vim.fn.fnamemodify(file, ":.")

				local blame = vim.fn.systemlist(
					string.format(
						"git blame -L %d,%d --porcelain %s",
						line_num,
						line_num,
						relative_file
					)
				)

				if vim.v.shell_error ~= 0 then
					vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
					vim.notify("Failed to get git blame", vim.log.levels.WARN)
					return
				end

				local commit_hash = blame[1]:match "^(%w+)"

				vim.cmd "vsplit"
				vim.cmd "enew"
				local buf = vim.api.nvim_get_current_buf()
				vim.fn.termopen("git show " .. commit_hash)

				vim.api.nvim_create_autocmd("BufWinLeave", {
					buffer = buf,
					once = true,
					callback = function()
						vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
					end,
				})

				vim.cmd "startinsert"
			end,
			desc = "Show commit details",
		},
		{
			"<Leader>gl",
			function()
				local original_cwd = vim.fn.getcwd()
				local file = vim.fn.expand "%:p"
				local file_dir = vim.fn.fnamemodify(file, ":h")
				local line_num = vim.fn.line "."

				vim.cmd("cd " .. vim.fn.fnameescape(file_dir))

				local git_root =
					vim.fn.systemlist("git rev-parse --show-toplevel")[1]
				if vim.v.shell_error ~= 0 then
					vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
					vim.notify(
						"File is not in a git repository",
						vim.log.levels.WARN
					)
					return
				end

				vim.cmd("cd " .. vim.fn.fnameescape(git_root))
				local relative_file = vim.fn.fnamemodify(file, ":.")

				vim.cmd "vsplit"
				vim.cmd "enew"
				local buf = vim.api.nvim_get_current_buf()
				vim.fn.termopen(
					string.format(
						"git log -L %d,%d:%s",
						line_num,
						line_num,
						relative_file
					)
				)

				vim.api.nvim_create_autocmd("BufWinLeave", {
					buffer = buf,
					once = true,
					callback = function()
						vim.cmd("cd " .. vim.fn.fnameescape(original_cwd))
					end,
				})

				vim.cmd "startinsert"
			end,
			desc = "Show git log for current line",
		},
	},
	event = "VeryLazy",
	config = function()
		require("gitblame").setup {
			enabled = false,
			date_format = "%x",
			message_when_not_committed = "",
			highlight_group = "GitSignsCurrentLineBlame",
		}
	end,
}
