return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"ff",
			function()
				require("conform").format()
			end,
			desc = "Format buffer",
		},
		{
			"ff",
			function()
				local s = vim.api.nvim_buf_get_mark(0, "<")
				local e = vim.api.nvim_buf_get_mark(0, ">")
				local end_line = vim.api.nvim_buf_get_lines(
					0,
					e[1] - 1,
					e[1],
					false
				)[1] or ""

				require("conform").format {
					range = {
						["start"] = { s[1], s[2] },
						["end"] = { e[1], math.min(e[2], #end_line) },
					},
				}
			end,
			mode = "v",
			desc = "Format selection",
		},
	},
	config = function()
		local typescript_setup = {
			-- "eslint_d",
			-- "oxlint",
			"oxfmt", -- "eslint",
			-- "prettierd",
			-- "prettier",
			-- "deno_fmt",
			stop_after_first = false,
		}
		require("conform").setup {
			formatters = {
				oxlint = {
					args = { "lint", "--fix", "--stdin-filename", "$FILENAME" },
				},

				clang_format = {
					timeout_ms = 1000,
					cwd = require("conform.util").root_file { ".clang-format" },
				},

				eslint_d = {
					timeout_ms = 1000,
					lsp_fallback = true,
				},
				prettierd = {
					cwd = require("conform.util").root_file {
						"package.json",
						".prettierrc",
					},
				},
				prettier = {
					cwd = require("conform.util").root_file {
						"package.json",
						".prettierrc",
					},
				},
				black = { prepend_args = { "--line-length", "100" } },
				tombi = {
					command = "tombi",
					prepend_args = { "format", "--offline", "-v" },
				},
				rumdl = {
					prepend_args = {
						"fmt",
					},
				},
				cbfmt = {
					prepend_args = {
						"--config",
						vim.env.HOME .. "/.config/cbfmt/cbfmt.toml",
					},
				},
				clang_format = { timeout_ms = 1000 },
				dprint = {
					timeout_ms = 500,
					lsp_format = "prefer",
					condition = function(ctx)
						return vim.fs.find(
							{ "dprint.json" },
							{ path = ctx.filename, upward = true }
						)[1]
					end,
				},
			},
			formatters_by_ft = {
				c = { "clang_format" },
				cpp = { "clang_format" },
				elixir = { "mix" },
				lua = { "stylua" },
				json = { "fixjson" },
				jsonc = {
					"deno_fmt",
					"prettierd",
					"prettier",
					"biome",
					stop_after_first = true,
				},
				toml = { "tombi", lsp_format = "fallback" },
				python = { "isort", "black" },
				rust = { "rustfmt", lsp_format = "fallback" },
				nix = { "alejandra", lsp_format = "fallback" },
				typescript = typescript_setup,
				typescriptreact = typescript_setup,
				javascript = typescript_setup,
				javascriptreact = typescript_setup,
				html = { "prettier", "prettierd", stop_after_first = true },
				xml = { "xmlformat", stop_after_first = true },
				astro = {
					"prettier",
					"prettierd",
					stop_after_first = true,
				},
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				markdown = {
					"prettierd",
					"rumdl",
					"dprint",
					"cbfmt",
					stop_after_first = true,
				},
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
		}
	end,
}
