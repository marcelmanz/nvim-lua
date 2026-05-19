local persistend_qfl = require "features.persistend-qfl"
local toggle_quickfix = require "utils.toggle-qf"

local opts = { noremap = true, silent = true }
local opt_ns = { noremap = true, silent = true }

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.api.nvim_set_keymap("n", "<Leader>sw", [[:%s/\<<C-r><C-w>\>//g<Left><Left>]], { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", "<Leader>nn", ":e ~/clones/pers/notes/notes.md<cr>", { noremap = true, silent = false })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<Right>", ":vertical resize -5<cr>", opt_ns)
vim.keymap.set("n", "<Left>", ":vertical resize +5<cr>", opt_ns)

vim.keymap.set("n", "cpp", "Vcp", { noremap = false, silent = true })
vim.keymap.set("n", "cP", "cp$", { noremap = false, silent = true })

vim.keymap.set("n", "n", "nzzzv", opt_ns)
vim.keymap.set("n", "N", "Nzzzv", opt_ns)
vim.keymap.set("n", "J", "mzJ`z", opt_ns)
vim.keymap.set("n", "U", "<C-R>", opt_ns)

vim.keymap.set("v", "<", "<gv", opt_ns)
vim.keymap.set("v", ">", ">gv", opt_ns)
vim.keymap.set("n", "^v", "^v<Esc>", opt_ns)

vim.keymap.set("n", "<leader>cd", ":cd %:p:h<cr>:pwd<cr>", opt_ns)
vim.keymap.set("i", "<c-x>", ":lua require('complextras').complete_line_from_cwd()", opt_ns)

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<Leader>w", ":w<cr>", opts)
vim.keymap.set("n", "<Leader>W", ":w!<cr>", opts)
vim.keymap.set("n", "<Leader>nw", ":noautocmd w<cr>", opts)
vim.keymap.set("c", "w!!", "SudaWrite<cr>", { noremap = false, silent = false })

local function is_qf_open()
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			return true
		end
	end
	return false
end

local function will_exit_nvim()
	local normal_windows = 0
	local current_tabpage = vim.api.nvim_get_current_tabpage()

	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.tabnr == current_tabpage then
			local buf = vim.api.nvim_win_get_buf(win.winid)
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
			if buftype == "" or buftype == "acwrite" then
				normal_windows = normal_windows + 1
			end
		end
	end

	local tabpages = vim.api.nvim_list_tabpages()
	return normal_windows <= 1 and #tabpages == 1
end

local function saveSession(opts)
	opts = opts or {}
	local filetype = string.lower(vim.bo.filetype)

	if string.match(filetype, "commit") then
		return
	end

	if not opts.force and not will_exit_nvim() then
		return
	end

	local started_with_files = vim.fn.argc() > 0
	local qf_open = is_qf_open()

	local function do_save()
		if qf_open and #vim.fn.getqflist() > 0 then
			persistend_qfl.QfSave()
		elseif not started_with_files then
			persistend_qfl.QfDeletePersistentFile()
		end
		vim.cmd "AutoSession save"
	end

	if opts.immediate then
		do_save()
	else
		vim.schedule(do_save)
	end
end

vim.keymap.set("n", "<Leader>q", function()
	saveSession()
	vim.cmd "q"
end, opts)

vim.keymap.set("n", "<Leader>Q", function()
	saveSession { force = true, immediate = true }
	vim.cmd "qa!"
end, opts)

vim.keymap.set("n", "<Leader>e", ":e<cr>", opts)

vim.keymap.set("n", "<Leader>sj", ":split<cr>", opts)
vim.keymap.set("n", "<Leader>sl", ":vsplit<cr>", opts)

vim.keymap.set("n", "<Leader>o", ":luafile %<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<Leader>so", ":luafile ~/.config/nvim/init.lua<cr>", { noremap = true, silent = false })

vim.keymap.set("n", "<leader>xo", "<cmd>source %<cr>", { desc = "Source current lua file" })

vim.keymap.set("v", "<leader>s", ":'<,'>sort<CR>", { desc = "Sort visual selection" })
vim.keymap.set("n", "<leader>sp", "vip:sort<CR>", { desc = "Sort current paragraph", silent = true })

local function source_for_lua_or_bash()
	if vim.bo.filetype == "lua" then
		vim.cmd ".lua"
	else
		vim.cmd "!chmod +x %"
	end
end

vim.keymap.set("n", "<leader>x", source_for_lua_or_bash, { desc = "Source current line in lua files" })
vim.keymap.set("v", "<leader>x", ":lua<cr>", { desc = "Source visual selection in lua files" })

vim.keymap.set("n", "<Leader>li", ":Lazy install<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<Leader>lu", ":Lazy update<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<Leader>lc", ":Lazy clean<cr>", { noremap = true, silent = false })
vim.keymap.set("n", "<Leader>ls", ":Lazy sync<cr>", { noremap = true, silent = false })

function Disable_lsp_virtual_text()
	print "LSP warnings disabled."
	return { virtual_text = false, signs = true, underline = false }
end

function Enable_lsp_virtual_text()
	print "LSP warnings enabled."
	return { virtual_text = true, signs = true, underline = false }
end

local function lsp_diagnostic_toggle()
	local virtual_text_is_enabled = vim.diagnostic.config().virtual_text == true
	if virtual_text_is_enabled then
		return Disable_lsp_virtual_text()
	else
		return Enable_lsp_virtual_text()
	end
end

function Lsp_diagnostic_toggle_with_message(force_config)
	force_config = force_config or false
	local diagnostic_config = force_config and force_config or lsp_diagnostic_toggle()
	vim.diagnostic.config(diagnostic_config)
end

vim.keymap.set("n", "<Leader>di", Lsp_diagnostic_toggle_with_message, { noremap = true, silent = false })

vim.keymap.set("n", "<leader>co", toggle_quickfix, opt_ns)
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<Leader>nh", ":noh<cr>")
vim.keymap.set("n", "<Leader>yf", ':let @+ = expand("%")<cr>')

vim.keymap.set("n", "<Leader>ac", ":AIChat<cr>")
vim.keymap.set("n", "<Leader>ai", ":AI ")
vim.keymap.set("v", "<Leader>ae", ":AIEdit ")

vim.keymap.set("n", "<leader>ta", typescript_server_import_all)

vim.keymap.set("n", "v", "v", opt_ns)
vim.keymap.set("n", "gf", "gF", opt_ns)

vim.keymap.set("n", "<Leader>tt", ":Todo<cr>", {
	noremap = true,
	silent = true,
	desc = "Open current date todo file using the Todo command",
})

local function StarWithDash(cmd)
	local isk = vim.bo.iskeyword
	vim.opt_local.iskeyword:append "-"
	vim.cmd("normal! " .. cmd)
	vim.bo.iskeyword = isk
end

vim.keymap.set("n", "<leader>*", function() StarWithDash "*" end, { noremap = true })
vim.keymap.set("n", "<leader>#", function() StarWithDash "#" end, { noremap = true })

vim.keymap.set("n", "<leader>tn", "<cmd>tabnew %<CR>", { desc = "Zoom current split (tab new)" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Unzoom tab (tabclose)" })

vim.keymap.set("n", "<leader>ya", function()
	local abs_path = vim.fn.expand "%:p"
	if abs_path == "" then
		vim.notify("No file in current buffer", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", abs_path)
	vim.notify("Copied: " .. abs_path, vim.log.levels.INFO)
end, { desc = "Copy absolute path to clipboard" })

vim.keymap.set("n", "<leader>yr", "<cmd>CopyRelPath<CR>", { desc = "Copy relative path to clipboard" })

vim.keymap.set("n", "<leader>mw", function() vim.cmd "MdWatch" end)

vim.keymap.set("n", "<C-^>", "<cmd>buffer #<CR>", { desc = "Alternate buffer" })

local vim_modes = "vn"
for mode in string.gmatch(vim_modes, "%a") do
	vim.keymap.set(mode, "ff", function(_, bufnr)
		require("conform").format()
		-- TODO: Check why diagnostics are cleared after formatting
		vim.diagnostic.enable(bufnr)
	end)
	vim.keymap.set(mode, "<leader>yf", function()
		vim.cmd [[silent!!yarn eslint --fix %]]
	end)
end

-- vim: ts=2 sts=2 sw=2 et
