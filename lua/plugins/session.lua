local function is_qf_open()
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			return true
		end
	end
	return false
end

local function has_file_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			vim.bo[buf].buflisted
			and vim.bo[buf].buftype == ""
			and vim.api.nvim_buf_get_name(buf) ~= ""
		then
			return true
		end
	end
	return false
end

return {
	"rmagatti/auto-session",
	cmd = { "AutoSession", "Autosession" },
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("auto-session").setup {
			log_level = "error",
			enabled = true,
			auto_save = true,
			auto_restore = false,
			args_allow_files_auto_save = true,
			auto_delete_empty_sessions = false,
			bypass_save_filetypes = { "gitcommit", "ministarter" },
			pre_save_cmds = {
				function()
					if
						string.match(string.lower(vim.bo.filetype), "commit")
					then
						return false
					end
					if not has_file_buffers() then
						return false
					end
				end,
				function()
					pcall(function()
						local persistend_qfl = require "features.persistend-qfl"
						if is_qf_open() and #vim.fn.getqflist() > 0 then
							persistend_qfl.QfSave()
						elseif vim.fn.argc() == 0 then
							persistend_qfl.QfDeletePersistentFile()
						end
					end)
				end,
				function()
					-- Wrap in pcall to prevent blocking on errors
					pcall(function()
						require("dart").write_auto_session()
					end)
				end,
			},
			post_restore_cmds = {
				function()
					-- Wrap in pcall to prevent blocking on errors
					pcall(function()
						require("dart").read_auto_session()
					end)
				end,
				function()
					-- Restore quickfix after session to prevent corruption
					vim.schedule(function()
						pcall(function()
							require("features.persistend-qfl").QfLoad {
								open = false,
							}
						end)
					end)
				end,
			},
			suppressed_dirs = {
				"~/",
				"~/Downloads",
				"/",
			},
		}
	end,
}
