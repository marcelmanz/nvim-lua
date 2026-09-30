return {
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		cmd = "Gitsigns",
		lazy = true,
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				-- add = { text = "│" },
				-- change = { text = "│" },
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
				delay = 500,
				ignore_whitespace = false,
				virt_text_priority = 100,
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				map({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						vim.cmd.normal { "]c", bang = true }
					else
						gs.nav_hunk("next", { target = "all" })
					end
				end, { desc = "Jump to next hunk" })

				map({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						vim.cmd.normal { "[c", bang = true }
					else
						gs.nav_hunk("prev", { target = "all" })
					end
				end, { desc = "Jump to previous hunk" })

				-- Actions
				-- visual mode
				map("v", "<leader>hs", function()
					gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
				end, { desc = "stage git hunk" })
				map("v", "<leader>hr", function()
					gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
				end, { desc = "reset git hunk" })
				-- normal mode
				map(
					"n",
					"<leader>hs",
					gs.stage_hunk,
					{ desc = "git stage hunk" }
				)
				map(
					"n",
					"<leader>hr",
					gs.reset_hunk,
					{ desc = "git reset hunk" }
				)
				map(
					"n",
					"<leader>hS",
					gs.stage_buffer,
					{ desc = "git Stage buffer" }
				)
				map(
					"n",
					"<leader>hu",
					gs.undo_stage_hunk,
					{ desc = "undo stage hunk" }
				)
				map(
					"n",
					"<leader>hR",
					gs.reset_buffer,
					{ desc = "git Reset buffer" }
				)
				map(
					"n",
					"<leader>hp",
					gs.preview_hunk,
					{ desc = "preview git hunk" }
				)
				map(
					"n",
					"<leader>hi",
					gs.preview_hunk_inline,
					{ desc = "preview git hunk inline" }
				)
				map("n", "<leader>hb", function()
					gs.blame_line { full = false }
				end, { desc = "git blame line" })
				map(
					"n",
					"<leader>hd",
					gs.diffthis,
					{ desc = "git diff against index" }
				)
				map("n", "<leader>hD", function()
					gs.diffthis "~"
				end, { desc = "git diff against last commit" })

				-- Toggles
				map(
					"n",
					"<leader>sb",
					gs.toggle_current_line_blame,
					{ desc = "toggle git blame line" }
				)
				map(
					"n",
					"<leader>td",
					gs.toggle_deleted,
					{ desc = "toggle git show deleted" }
				)

				-- Text object
				map(
					{ "o", "x" },
					"ih",
					":<C-U>Gitsigns select_hunk<CR>",
					{ desc = "select git hunk" }
				)

				map(
					"n",
					"<Leader>glt",
					":Gitsigns toggle_current_line_blame<CR>",
					{ noremap = true, silent = false }
				)

				-- map(
				-- 	"n",
				-- 	"<Leader>gt",
				-- 	":Gitsigns blame<cr>",
				-- 	{ noremap = true, silent = false }
				-- )

				-- Set git current line blame highlight to the
				-- same as visual mode. If not set, it will be hidden
				-- This happens with kanagawa dragon afaik
				vim.api.nvim_set_hl(
					0,
					"GitSignsCurrentLineBlame",
					{ link = "Visual" }
				)
			end,
		},
	},
}
