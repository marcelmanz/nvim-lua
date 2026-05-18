---@brief
---
--- https://github.com/astral-sh/ruff
---
--- A fast Python linter and formatter, written in Rust.
--- `ruff server` provides LSP diagnostics and code actions (fix imports, etc.)
---
--- Install: `pip install ruff` or `uv tool install ruff`
---
--- Note: does NOT provide completions/hover/go-to-def.
--- Pair with basedpyright (lsp/basedpyright.lua) for full IDE features.

---@type vim.lsp.Config
return {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"ruff.toml",
		".ruff.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		".git",
	},
	settings = {
		ruff = {
			lint = {
				-- matches your current pycodestyle maxLineLength
				args = { "--line-length", "100" },
			},
		},
	},
}
