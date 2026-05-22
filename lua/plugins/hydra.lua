return {
	"nvimtools/hydra.nvim",
	keys = { "<C-g>", "<C-.>" },
	dependencies = { "lewis6991/gitsigns.nvim" },
	lazy = true,
	config = function()
		local Hydra = require "hydra"
		local gitsigns = require "gitsigns"
		local incdec = require "features.incdec"

		local git_hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: deleted      _b_: blame line
 _K_: prev hunk   _u_: undo stage        _p_: preview      _B_: blame full
 ^ ^              _S_: stage buffer      ^ ^               _/_: base file
 ^ ^              _<Enter>_: Neogit      _q_: exit
]]

		Hydra {
			name = "Git",
			mode = { "n", "x" },
			hint = git_hint,
			body = "<C-g>",
			config = {
				color = "pink",
				invoke_on_body = true,
			},
			heads = {
				{
					"J",
					function()
						gitsigns.next_hunk()
					end,
				},
				{
					"K",
					function()
						gitsigns.prev_hunk()
					end,
				},
				{ "s", ":Gitsigns stage_hunk<CR>", { silent = true } },
				{ "u", gitsigns.undo_stage_hunk },
				{ "S", gitsigns.stage_buffer },
				{ "p", gitsigns.preview_hunk },
				{ "d", gitsigns.toggle_deleted, { nowait = true } },
				{ "b", gitsigns.blame_line },
				{
					"B",
					function()
						gitsigns.blame_line { full = true }
					end,
				},
				{ "/", gitsigns.show, { exit = true } },
				{ "<Enter>", "<Cmd>Neogit<CR>", { exit = true } },
				{ "q", nil, { exit = true } },
			},
		}

		local incdec_hint = [[
 ^Move^        ^Adjust^
 _n_: next     _y_: +year/major   _Y_: -year/major 
 _N_: prev     _m_: +month/minor  _M_: -month/minor 
 ^ ^           _d_: +day/patch    _D_: -day/patch 
 ^ ^           _q_: quit
]]

		local function smart_adjust(delta, part)
			local t = incdec.detect_type()
			if not t then
				return
			end
			if t == "version" then
				if part == "year" then
					part = "major"
				elseif part == "month" then
					part = "minor"
				elseif part == "day" then
					part = "patch"
				end
			end
			incdec.adjust(delta, part)
		end

		Hydra {
			name = "Increment / Decrement",
			mode = "n",
			body = "<C-.>",
			hint = incdec_hint,
			config = {
				color = "amaranth", -- modal behavior
				invoke_on_body = true,
				-- hint = { border = "rounded" },
			},
			heads = {
				-- Navigation
				{
					"n",
					function()
						incdec.jump(true)
					end,
					{ desc = "Next match" },
				},
				{
					"N",
					function()
						incdec.jump(false)
					end,
					{ desc = "Prev match" },
				},

				-- Adjust: year/major
				{
					"y",
					function()
						smart_adjust(1, "year")
					end,
					{ desc = "Increase year/major" },
				},
				{
					"Y",
					function()
						smart_adjust(-1, "year")
					end,
					{ desc = "Decrease year/major" },
				},

				-- Adjust: month/minor
				{
					"m",
					function()
						smart_adjust(1, "month")
					end,
					{ desc = "Increase month/minor" },
				},
				{
					"M",
					function()
						smart_adjust(-1, "month")
					end,
					{ desc = "Decrease month/minor" },
				},

				-- Adjust: day/patch
				{
					"d",
					function()
						smart_adjust(1, "day")
					end,
					{ desc = "Increase day/patch" },
				},
				{
					"D",
					function()
						smart_adjust(-1, "day")
					end,
					{ desc = "Decrease day/patch" },
				},

				-- Exit
				{ "q", nil, { exit = true, desc = "Quit" } },
			},
		}
	end,
}
