local runner = require "lib.runner"

vim.api.nvim_create_autocmd("FileType", {
	pattern = "c",
	callback = function()
		local function has_make_run()
			local file_dir = vim.fn.expand "%:h"
			local makefile_path = file_dir == "" and "Makefile"
				or file_dir .. "/Makefile"
			if vim.fn.filereadable(makefile_path) == 1 then
				local _result = vim.fn.system( -- bin: make
					"cd " .. file_dir .. " && make -n run 2>/dev/null"
				)
				return vim.v.shell_error == 0
			end
			return false
		end

		local function get_build_cmd()
			if has_make_run() then
				return "make"
			else
				return "gcc "
					.. vim.fn.expand "%"
					.. " -o "
					.. vim.fn.expand "%<"
			end
		end

		local function get_command(args)
			local file_dir = vim.fn.expand "%:h"

			if has_make_run() then
				if args ~= "" then
					return "cd "
						.. file_dir
						.. " && make run ARGS='"
						.. args
						.. "'"
				else
					return "cd " .. file_dir .. " && make run"
				end
			else
				local binary = vim.fn.expand "%<"
				local cmd = "cd "
					.. file_dir
					.. " && "
					.. get_build_cmd()
					.. " && "
					.. binary
				if args ~= "" then
					cmd = cmd .. " " .. args
				end
				return cmd
			end
		end

		local r = runner.create(get_command, { use_tmux = true })

		vim.keymap.set(
			"n",
			"<leader>r",
			r.run,
			{ buffer = true, silent = true }
		)

		vim.keymap.set("n", "<leader>R", function()
			r.run(vim.fn.input "Args: ")
		end, { buffer = true, silent = true })

		vim.keymap.set(
			"n",
			"<leader>rd",
			r.run_with_diff,
			{ buffer = true, silent = true }
		)

		vim.keymap.set("n", "<leader>rD", function()
			r.run_with_diff(vim.fn.input "Args: ")
		end, { buffer = true, silent = true })
	end,
})
