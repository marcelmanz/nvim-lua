return {
	"rmagatti/auto-session",
	cmd = { "AutoSession", "Autosession" },
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("auto-session").setup {
			log_level = "error",
			auto_session_enabled = false,
			auto_save_enabled = false,
			pre_save_cmds = {
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
			auto_session_suppress_dirs = {
				"~/",
				"~/Downloads",
				"/",
			},
		}
	end,
}
