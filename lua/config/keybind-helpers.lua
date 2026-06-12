-- keybind-helpers.lua
-- Temporary reminder mappings for keybinds removed in Phase 2 refactor.
-- Each fires a notification with the new key, then still executes the action.
-- Delete this file once muscle memory is built.

local function remind(old, new, action)
	return function()
		vim.notify(
			("'%s' removed — use '%s'"):format(old, new),
			vim.log.levels.WARN,
			{ title = "Keybind reminder" }
		)
		if action then
			action()
		end
	end
end

-- LSP: rename  (native grn)
vim.keymap.set(
	"n",
	"<leader>rn",
	remind("<leader>rn", "grn", vim.lsp.buf.rename),
	{ desc = "DEPRECATED: use grn" }
)

-- LSP: code action  (native gra — fzf-lua wired in on_attach)
-- vim.keymap.set(
-- 	"n",
-- 	"<leader>a",
-- 	remind("<leader>a", "gra", function()
-- 		require("fzf-lua").lsp_code_actions()
-- 	end),
-- 	{ desc = "DEPRECATED: use gra" }
-- )

-- LSP: implementation  (native gri — fzf-lua wired in on_attach)
-- (gI was buffer-local; now global reminder is fine since it was removed from on_attach)
vim.keymap.set(
	"n",
	"gI",
	remind("gI", "gri", function()
		require("fzf-lua").lsp_implementations()
	end),
	{ desc = "DEPRECATED: use gri" }
)

-- NOTE: 'gr' → 'grr' cannot be remapped here — 'gr' is a prefix for the
-- native gr* family (grn/grr/gri/gra). Mapping it would shadow all of them.
-- Just remember: gr → grr.

-- Buffer nav  (native [b / ]b)
vim.keymap.set(
	"n",
	"<leader>bn",
	remind("<leader>bn", "[b", function()
		vim.cmd "bnext"
	end),
	{ desc = "DEPRECATED: use [b" }
)

vim.keymap.set(
	"n",
	"<leader>bp",
	remind("<leader>bp", "]b", function()
		vim.cmd "bprev"
	end),
	{ desc = "DEPRECATED: use ]b" }
)

vim.keymap.set(
	"n",
	"<leader><",
	remind("<leader><", "[b (repeat)", function()
		vim.cmd "bfirst"
	end),
	{ desc = "DEPRECATED: use [b" }
)

vim.keymap.set(
	"n",
	"<leader>>",
	remind("<leader>>", "]b (repeat)", function()
		vim.cmd "blast"
	end),
	{ desc = "DEPRECATED: use ]b" }
)

-- vim: ts=2 sts=2 sw=2 et
