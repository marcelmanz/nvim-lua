local persistend_qfl = require "features.persistend-qfl"
local toggle_quickfix = require "utils.toggle-qf"

local opts = { noremap = true, silent = true }
-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set(
	"n",
	"k",
	"v:count == 0 ? 'gk' : 'k'",
	{ expr = true, silent = true }
)
vim.keymap.set(
	"n",
	"j",
	"v:count == 0 ? 'gj' : 'j'",
	{ expr = true, silent = true }
)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump { count = -1, float = true }
end, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump { count = 1, float = true }
end, { desc = "Go to next diagnostic message" })
vim.keymap.set(
	"n",
	"<leader>e",
	vim.diagnostic.open_float,
	{ desc = "Open floating diagnostic message" }
)
vim.keymap.set(
	"n",
	"<leader>q",
	vim.diagnostic.setloclist,
	{ desc = "Open diagnostics list" }
)

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group =
	vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

vim.api.nvim_set_keymap(
	"n",
	"<Leader>sw",
	[[:%s/\<<C-r><C-w>\>//g<Left><Left>]],
	{ noremap = true, silent = false }
)
vim.api.nvim_set_keymap(
	"n",
	"<Leader>nn",
	":e ~/clones/pers/notes/notes.md<cr>",
	{ noremap = true, silent = false }
)

-- vim.api.nvim_set_keymap(
-- 	"n",
-- 	"<Leader>x",
-- 	":normal ddGp<cr>",
-- 	{ noremap = true, silent = false }
-- )

local opt_ns = { noremap = true, silent = true }

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- vim.keymap.set("n", "<c-s-o>", "<c-o>")

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<Right>", ":vertical resize -5<cr>", opt_ns)
vim.keymap.set("n", "<Left>", ":vertical resize +5<cr>", opt_ns)
-- vim.keymap.set("n", "<Down>", ":resize -5<cr>", opt_ns)
-- vim.keymap.set("n", "<Up>", ":resize +5<cr>", opt_ns)
vim.keymap.set("n", "Y", "y$", opt_ns)

-- christoomey/vim-system-copy
vim.keymap.set("n", "cpp", "Vcp", { noremap = false, silent = true })
vim.keymap.set("n", "cP", "cp$", { noremap = false, silent = true })

vim.keymap.set("n", "n", "nzzzv", opt_ns)
vim.keymap.set("n", "N", "Nzzzv", opt_ns)
vim.keymap.set("n", "J", "mzJ`z", opt_ns)

-- redo
vim.keymap.set("n", "U", "<C-R>", opt_ns)

vim.keymap.set(
	"n",
	"<expr> k",
	[[ (v:count > 5 ? "m'" . v:count : "") . 'k' ]],
	opt_ns
)
vim.keymap.set(
	"n",
	"<expr> j",
	[[ (v:count > 5 ? "m'" . v:count : "") . 'j' ]],
	opt_ns
)

-- search and replace
-- vim.keymap.set("n", "cn", "*``cgn", opt_ns)
-- LuaFormatter off
-- vim.keymap.set("n", "cN", "*``cgN", opt_ns)
-- better tabbing
vim.keymap.set("v", "<", "<gv", opt_ns)
vim.keymap.set("v", ">", ">gv", opt_ns)
vim.keymap.set("n", "^v", "^v<Esc>", opt_ns)

-- quick cd to buffer file
vim.keymap.set("n", "<leader>cd", ":cd %:p:h<cr>:pwd<cr>", opt_ns)
-- complextras
vim.keymap.set(
	"i",
	"<c-x>",
	":lua require('complextras').complete_line_from_cwd()",
	opt_ns
)

vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]
)
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- space as leader key
vim.keymap.set("n", "<Space>", "<NOP>", opts)

-- leader w to save
vim.keymap.set("n", "<Leader>w", ":w<cr>", opts)
-- leader W to save
vim.keymap.set("n", "<Leader>W", ":w!<cr>", opts)
-- leader W with no autocmd
vim.keymap.set("n", "<Leader>nw", ":noautocmd w<cr>", opts)
-- leader W to save ON SUDO
vim.keymap.set("c", "w!!", "SudaWrite<cr>", { noremap = false, silent = false })

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
			local buftype =
				vim.api.nvim_get_option_value("buftype", { buf = buf })
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

-- leader q to quit
-- and save session with auto-session
vim.keymap.set("n", "<Leader>q", function()
	saveSession()
	vim.cmd "q"
end, opts)

-- leader Q to quit!
-- and save session with auto-session
vim.keymap.set("n", "<Leader>Q", function()
	saveSession { force = true, immediate = true }
	vim.cmd "qa!"
end, opts)

-- leader a to autoread current file
vim.keymap.set("n", "<Leader>e", ":e<cr>", opts)

-- horizontal & vertical split
vim.keymap.set("n", "<Leader>sj", ":split<cr>", opts)
vim.keymap.set("n", "<Leader>sl", ":vsplit<cr>", opts)

vim.keymap.set(
	"n",
	"<Leader>o",
	":luafile %<cr>",
	{ noremap = true, silent = false }
)
vim.keymap.set(
	"n",
	"<Leader>so",
	":luafile ~/.config/nvim/init.lua<cr>",
	{ noremap = true, silent = false }
)

vim.keymap.set(
	"n",
	"<leader>xo",
	"<cmd>source %<cr>",
	{ desc = "Source current lua file" }
)

vim.keymap.set(
	"v",
	"<leader>s",
	":'<,'>sort<CR>",
	{ desc = "Sort visual selection" }
)

vim.keymap.set("n", "<leader>sp", "vip:sort<CR>", {
	desc = "Sort current paragraph",
	silent = true,
})

local function source_for_lua_or_bash()
	if vim.bo.filetype == "lua" then
		vim.cmd ".lua"
	else
		vim.cmd "!chmod +x %"
	end
end

vim.keymap.set(
	"n",
	"<leader>x",
	source_for_lua_or_bash,
	{ desc = "Source current line in lua files" }
)

vim.keymap.set(
	"v",
	"<leader>x",
	":lua<cr>",
	{ desc = "Source visual selection in lua files" }
)

-- switch windows vertically
-- vim.keymap.set("n", "<Leader>l", ":wincmd L<cr>", opts)
-- -- switch windows horizontally
-- vim.keymap.set("n", "<Leader>j", ":wincmd J<cr>", opts)

-- Lazy
vim.keymap.set(
	"n",
	"<Leader>li",
	":Lazy install<cr>",
	{ noremap = true, silent = false }
)
vim.keymap.set(
	"n",
	"<Leader>lu",
	":Lazy update<cr>",
	{ noremap = true, silent = false }
)
vim.keymap.set(
	"n",
	"<Leader>lc",
	":Lazy clean<cr>",
	{ noremap = true, silent = false }
)
vim.keymap.set(
	"n",
	"<Leader>ls",
	":Lazy sync<cr>",
	{ noremap = true, silent = false }
)

-- lsp
-- vim.keymap.set("n", "<Leader>dd", function()
-- 	vim.diagnostic.config {
-- 		virtual_text = false,
-- 		signs = true,
-- 		underline = false,
-- 	}
-- 	print "LSP warnings disabled."
-- end, { noremap = true, silent = false })

function Disable_lsp_virtual_text()
	print "LSP warnings disabled."
	return {
		virtual_text = false,
		signs = true,
		underline = false,
	}
end

function Enable_lsp_virtual_text()
	print "LSP warnings enabled."
	return {
		virtual_text = true,
		signs = true,
		underline = false,
	}
end

local function lsp_diagnostic_toggle()
	local diagnostic_config
	local virtual_text_is_enabled = vim.diagnostic.config().virtual_text == true
	if virtual_text_is_enabled then
		diagnostic_config = Disable_lsp_virtual_text()
	else
		diagnostic_config = Enable_lsp_virtual_text()
	end
	return diagnostic_config, virtual_text_is_enabled
end

function Lsp_diagnostic_toggle_with_message(force_config)
	force_config = force_config or false
	local diagnostic_config = force_config and force_config
		or lsp_diagnostic_toggle()
	vim.diagnostic.config(diagnostic_config)
end

vim.keymap.set(
	"n",
	"<Leader>di",
	Lsp_diagnostic_toggle_with_message,
	{ noremap = true, silent = false }
)

-- ; for :
-- vim.keymap.set("n", ";", ":", { noremap = true, silent = false })
-- vim.keymap.set("n", ":", ";", { noremap = true, silent = false })

-- quickfix
vim.keymap.set("n", "<leader>co", toggle_quickfix, opt_ns)
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<Leader>cn", ":cn<cr>")
-- vim.keymap.set("n", "<Leader>cp", ":cp<cr>")

-- nohighlight
vim.keymap.set("n", "<Leader>nh", ":noh<cr>")

-- rename
vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename)

-- copy relative filename to clipboard
vim.keymap.set("n", "<Leader>yf", ':let @+ = expand("%")<cr>')

-- AI
vim.keymap.set("n", "<Leader>ac", ":AIChat<cr>")
vim.keymap.set("n", "<Leader>ai", ":AI ")
vim.keymap.set("v", "<Leader>ae", ":AIEdit ")

-- Typescript
vim.keymap.set("n", "<leader>ta", typescript_server_import_all)

-- open file path under cursor vertical split
-- vim.keymap.set('n', '<Leader>gf', ':vertical wincmd f<cr>',
--                         {noremap = true, silent = true})

-- vim.keymap.set('v', '<C-r>',
-- ':hy:%Subvert/<C-r>h//gc<left><left><left>',
-- {noremap = true, silent = false})
vim.keymap.set("n", "v", "v", opt_ns)

-- Same as "gf" except if a number follow the file name the cursor goes to that
-- specific line
vim.keymap.set("n", "gf", "gF", opt_ns)
-- vim.keymap.set("n", "vv", "V", opt_ns)
-- vim.keymap.set("n", "V", "v$", opt_ns)
-- vim.keymap.set("n", "<Leader>Y", '"+y$l', opt_ns)

-- keymap to mark a todo as done in markdown
-- more info in ./commands.lua:15:
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

vim.keymap.set("n", "<leader>*", function()
	StarWithDash "*"
end, { noremap = true })

vim.keymap.set("n", "<leader>#", function()
	StarWithDash "#"
end, { noremap = true })

-- Tab management
vim.keymap.set(
	"n",
	"<leader>tn",
	"<cmd>tabnew %<CR>",
	{ desc = "Zoom current split (tab new)" }
)
vim.keymap.set(
	"n",
	"<leader>tc",
	"<cmd>tabclose<CR>",
	{ desc = "Unzoom tab (tabclose)" }
)

-- Absolute path to system clipboard
vim.keymap.set("n", "<leader>ya", function()
	local abs_path = vim.fn.expand "%:p"
	if abs_path == "" then
		vim.notify("No file in current buffer", vim.log.levels.WARN)
		return
	end
	vim.fn.setreg("+", abs_path)
	vim.notify("Copied: " .. abs_path, vim.log.levels.INFO)
end, { desc = "Copy absolute path to clipboard" })

-- Relative path to system clipboard
vim.keymap.set(
	"n",
	"<leader>yr",
	"<cmd>CopyRelPath<CR>",
	{ desc = "Copy relative path to clipboard" }
)

-- Markdown preview
vim.keymap.set("n", "<leader>mw", function()
	vim.cmd "MdWatch"
end)

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set(
	"n",
	"<leader>bp",
	"<cmd>bprev<CR>",
	{ desc = "Previous buffer" }
)
vim.keymap.set("n", "<leader><", "<cmd>bfirst<CR>", { desc = "First buffer" })
vim.keymap.set("n", "<leader>>", "<cmd>blast<CR>", { desc = "Last buffer" })
vim.keymap.set("n", "<C-^>", "<cmd>buffer #<CR>", { desc = "Alternate buffer" })

-- custom git blame
-- vim.keymap.set("n", "<leader>gb", ":GitBlameLine<cr>", { desc = "Git blame line with Tig" })

-- just trying
local vim_modes = "vn"
for mode in string.gmatch(vim_modes, "%a") do
	vim.keymap.set(mode, "ff", function(_, bufnr)
		require("conform").format()
		-- vim.lsp.buf.format {
		-- 	filter = function(client)
		-- 		return client.name ~= "tsserver"
		-- 	end,
		-- }

		-- TODO: Check why diagnostics are cleared after formating
		vim.diagnostic.enable(bufnr)
	end) -- { timeout_ms = 2000 }
	vim.keymap.set(mode, "<leader>yf", function()
		vim.cmd [[silent!!yarn eslint --fix %]]
	end) -- { timeout_ms = 2000 }
end

-- vim: ts=2 sts=2 sw=2 et
