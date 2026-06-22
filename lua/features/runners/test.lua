local tmux = require "lib.tmux"

local function get_rust_test_under_cursor()
	local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
	local current_line = vim.api.nvim_get_current_line()

	local test_name = current_line:match "fn ([%w_]+)"
	if test_name then
		for i = current_line_num - 1, math.max(1, current_line_num - 5), -1 do
			local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
			if line and line:match "#%[test%]" then
				return test_name
			end
		end
	end

	return nil
end

local function get_cpp_test_under_cursor()
	local current_line_num = vim.api.nvim_win_get_cursor(0)[1]

	for i = current_line_num, 1, -1 do
		local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
		if line then
			local suite, name =
				line:match "TEST_?[FP]?%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)"
			if suite and name then
				return suite .. "." .. name
			end
		end
	end

	return nil
end

local function RunFileTests()
	local fname = vim.fn.expand "%:t"
	local filepath = vim.fn.expand "%:p"
	local filestem = vim.fn.expand "%:p:r"
	local ext = vim.fn.expand "%:e"

	if ext == "rs" then
		local specific_test = get_rust_test_under_cursor()
		local test_target = specific_test or vim.fn.expand "%:t:r"
		local cmd = string.format(
			"direnv exec . cargo test %s -- --show-output",
			test_target
		)
		tmux.create_tmux_persistent_command(cmd)
	elseif ext == "js" or ext == "ts" or ext == "jsx" or ext == "tsx" then
		if fname:match("%.tests?%." .. ext .. "$") then
			tmux.create_tmux_persistent_command("npm run test " .. filepath)
		else
			local basename = vim.fn.expand "%:t:r"
			local dir = vim.fn.expand "%:p:h"
			local candidates = {
				dir .. "/" .. basename .. ".test." .. ext,
				dir .. "/" .. basename .. ".tests." .. ext,
				dir .. "/tests/" .. basename .. ".test." .. ext,
				dir .. "/tests/" .. basename .. ".tests." .. ext,
				dir
					.. "/"
					.. basename
					.. "/tests/"
					.. basename
					.. ".test."
					.. ext,
				dir
					.. "/"
					.. basename
					.. "/tests/"
					.. basename
					.. ".tests."
					.. ext,
			}
			local test_file
			for _, path in ipairs(candidates) do
				if vim.fn.filereadable(path) == 1 then
					test_file = path
					break
				end
			end
			if not test_file then
				test_file = candidates[#candidates]
			end
			tmux.create_tmux_persistent_command("npm run test " .. test_file)
		end
	elseif ext == "py" then
		local project_root = vim.fn.getcwd()
		local root_esc = vim.fn.shellescape(project_root)
		local docker_cmd = "cd "
			.. root_esc
			.. " && docker build -f test.Dockerfile -t test-runner . && docker run --rm --env-file "
			.. vim.fn.shellescape "ENV/test.env"
			.. " test-runner python -m pytest -c ./pytest.ini"

		if fname == "conftest.py" then
			local dir = vim.fn.expand "%:p:h"
			local relative_dir = string.gsub(
				dir,
				"^" .. project_root:gsub("([^%w])", "%%%1") .. "/",
				""
			)
			if relative_dir == "" then
				relative_dir = "."
			end
			local cmd = docker_cmd
				.. " "
				.. vim.fn.shellescape(relative_dir)
				.. " -vv"
			tmux.create_tmux_persistent_command(cmd)
		else
			local relative_file = string.gsub(
				vim.fn.expand "%:p",
				"^" .. project_root:gsub("([^%w])", "%%%1") .. "/",
				""
			)
			local cmd = docker_cmd
				.. " "
				.. vim.fn.shellescape(relative_file)
				.. " -vv"
			tmux.create_tmux_persistent_command(cmd)
		end
	elseif ext == "cpp" or ext == "cc" or ext == "cxx" then
		local project_root = vim.fn.getcwd()
		local build_dir = project_root .. "/build"
		local target = vim.fn.expand "%:t:r"
		local binary = build_dir .. "/" .. target
		local specific_test = get_cpp_test_under_cursor()

		local run_cmd = binary
		if specific_test then
			run_cmd = run_cmd .. " --gtest_filter=" .. specific_test
		end

		local cmd = string.format(
			"cmake -B %s && cmake --build %s --target %s --parallel 8 && %s",
			build_dir,
			build_dir,
			target,
			run_cmd
		)

		if project_root:match "network%-manager" then
			cmd = string.format(
				'nix develop %s --command bash -c "%s"',
				vim.fn.expand "~/clones/own/dev-templates/network-manager",
				cmd
			)
		end

		tmux.create_tmux_persistent_command(cmd)
	else
		print "RunTests: unsupported filetype"
	end
end

vim.api.nvim_create_user_command(
	"RunTests",
	RunFileTests,
	{ desc = "Run tests for current file in tmux window", nargs = 0 }
)

vim.keymap.set(
	"n",
	"<leader>rt",
	RunFileTests,
	{ desc = "Run tests for current file", silent = true }
)
