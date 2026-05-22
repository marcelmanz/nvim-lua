local M = {}

local function get_vale_accept_path()
	local cwd = vim.fn.getcwd()
	local vale_ini = cwd .. "/.vale.ini"
	local base_path = cwd

	if vim.fn.filereadable(vale_ini) == 0 then
		vale_ini = vim.fn.expand "~/.config/vale/.vale.ini"
		base_path = vim.fn.expand "~"

		if vim.fn.filereadable(vale_ini) == 0 then
			return nil,
				"No .vale.ini found in current directory or ~/.config/vale/.vale.ini"
		end
	end

	local lines = vim.fn.readfile(vale_ini)
	local vocab_name = "Base"

	for _, line in ipairs(lines) do
		local match = line:match "^%s*Vocab%s*=%s*(.+)%s*$"
		if match then
			vocab_name = match
			break
		end
	end

	local accept_path = base_path
		.. "/.vale/styles/config/vocabularies/"
		.. vocab_name
		.. "/accept.txt"
	return accept_path, nil
end

function M.add_word_to_accept()
	local word = vim.fn.expand "<cword>"

	if word == "" then
		vim.notify("No word under cursor", vim.log.levels.WARN)
		return
	end

	local accept_path, err = get_vale_accept_path()
	if err then
		vim.notify(err, vim.log.levels.ERROR)
		return
	end

	local dir = vim.fn.fnamemodify(accept_path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end

	local existing_words = {}
	if vim.fn.filereadable(accept_path) == 1 then
		local lines = vim.fn.readfile(accept_path)
		for _, line in ipairs(lines) do
			existing_words[line] = true
		end
	end

	if existing_words[word] then
		vim.notify(
			"'" .. word .. "' already in accept list",
			vim.log.levels.INFO
		)
		return
	end

	local file = io.open(accept_path, "a")
	if not file then
		vim.notify("Failed to open " .. accept_path, vim.log.levels.ERROR)
		return
	end

	file:write(word .. "\n")
	file:close()

	vim.notify(
		"Added '" .. word .. "' to Vale accept list",
		vim.log.levels.INFO
	)

	vim.cmd "silent write"
end

vim.keymap.set("n", "<leader>va", function()
	M.add_word_to_accept()
end, { desc = "Add word under cursor to Vale accept list" })

return M
