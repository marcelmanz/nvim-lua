local M = {}

-- Binaries aren't tracked in one hand-maintained list: they're discovered from
-- how the config already names them, so a new tool gets picked up automatically
-- as long as it's introduced the same way as everything else:
--   - an LSP server: lsp/<name>.lua's cmd table (see lsp_bins below)
--   - guarded via a vim.fn.executable or vim.fn.exepath call before use
--   - passed as the first argv element to a vim.fn.jobstart/system table call
--   - anything else (built via string.format, string concat, etc.): tag that
--     line with a trailing comment: two dashes, "bin:", then the binary name
-- Formatters are not covered here: conform.nvim already reports their
-- availability per filetype, run :ConformInfo in a buffer.

local function rg_capture(root, pattern)
	local out = vim.fn.systemlist {
		"rg",
		"--type",
		"lua",
		"--no-heading",
		"--no-filename",
		"--no-line-number",
		"-o",
		"-r",
		"$1",
		"-e",
		pattern,
		root,
	}
	return vim.v.shell_error == 0 and out or {}
end

local function lsp_bins()
	local bins = {}
	for _, file in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
		local name = vim.fn.fnamemodify(file, ":t:r")
		local ok, cfg = pcall(function()
			return vim.lsp.config[name]
		end)
		if ok and type(cfg) == "table" and cfg.cmd and cfg.cmd[1] then
			table.insert(bins, { label = name .. " (lsp)", bin = cfg.cmd[1] })
		end
	end
	return bins
end

function M.check()
	local root = vim.fn.stdpath "config"

	vim.health.start "LSP servers (lsp/*.lua)"
	for _, entry in ipairs(lsp_bins()) do
		if entry.bin ~= "" and vim.fn.executable(entry.bin) == 1 then
			vim.health.ok(entry.label .. " -> " .. entry.bin)
		else
			vim.health.warn(
				entry.label .. ": " .. entry.bin .. " not on PATH, add it to flake.nix"
			)
		end
	end

	local found = {}
	for _, bin in ipairs(rg_capture(root, [[vim\.fn\.(?:exepath|executable)\s*"([a-zA-Z0-9_.+-]+)"]])) do
		found[bin] = true
	end
	for _, bin in ipairs(rg_capture(root, [[vim\.fn\.(?:jobstart|system)\(\s*\{\s*"([a-zA-Z0-9_.+-]+)"]])) do
		found[bin] = true
	end
	for _, bin in ipairs(rg_capture(root, [[--\s*bin:\s*([a-zA-Z0-9_.+-]+)]])) do
		found[bin] = true
	end

	local bins = vim.tbl_keys(found)
	table.sort(bins)

	vim.health.start "Shelled-out binaries (vim.fn.executable/exepath, jobstart/system argv, `-- bin:` tags)"
	for _, bin in ipairs(bins) do
		if vim.fn.executable(bin) == 1 then
			vim.health.ok(bin)
		else
			vim.health.warn(bin .. " not on PATH, add it to flake.nix")
		end
	end

	vim.health.info "Formatters: run `:ConformInfo` in a buffer for per-filetype availability"
end

return M
