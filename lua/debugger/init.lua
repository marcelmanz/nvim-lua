-- Minimal framework for registering nvim-dap adapters/configurations per language.
--
-- Each language lives in `lua/debugger/langs/<name>.lua` and returns a table:
--   {
--     adapters = { <adapter_name> = <adapter_spec> },   -- merged into dap.adapters
--     configurations = { <filetype> = { <config>, ... } }, -- merged into dap.configurations
--     setup = function(dap) end,                         -- optional extra wiring
--   }
--
-- To add a new language: create the module and add its name to `langs` below.

local M = {}

local langs = {
	"cpp",
}

function M.setup()
	local dap = require "dap"

	for _, name in ipairs(langs) do
		local ok, mod = pcall(require, "debugger.langs." .. name)
		if not ok then
			vim.notify(
				"debugger: failed to load lang module '" .. name .. "': " .. mod,
				vim.log.levels.ERROR
			)
		else
			for adapter_name, adapter in pairs(mod.adapters or {}) do
				dap.adapters[adapter_name] = adapter
			end
			for filetype, configurations in pairs(mod.configurations or {}) do
				dap.configurations[filetype] = configurations
			end
			if type(mod.setup) == "function" then
				mod.setup(dap)
			end
		end
	end
end

return M
