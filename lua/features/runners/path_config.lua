local M = {}

-- Per-path runner overrides. First entry whose `path` is a prefix of the
-- current directory wins. Define either `prefix` (string prepended to the
-- command) or `wrap` (function receiving the command, returning a new one).
M.configs = {
	{
		path = vim.fn.expand "~/clones/work/network-manager",
		wrap = function(cmd)
			return string.format(
				"nix develop %s --command bash -c %s",
				vim.fn.shellescape(
					vim.fn.expand "~/clones/own/dev-templates/network-manager"
				),
				vim.fn.shellescape(cmd)
			)
		end,
	},
}

function M.wrap(cmd, dir)
	dir = dir or vim.fn.getcwd()
	for _, cfg in ipairs(M.configs) do
		if dir:sub(1, #cfg.path) == cfg.path then
			if cfg.wrap then
				return cfg.wrap(cmd)
			elseif cfg.prefix then
				return cfg.prefix .. " " .. cmd
			end
		end
	end
	return cmd
end

return M
