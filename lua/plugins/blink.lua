local function get_plus_than_node(v)
	local node_version
	local home = vim.fn.expand "$HOME"
	local fnm_path = home .. "/.local/share/fnm/node-versions"
	local entries = vim.fn.glob(fnm_path .. "/*", false, true)

	local node_path

	for _, entry in ipairs(entries) do
		local major, minor, patch = entry:match "v(%d+)%.(%d+)%.(%d+)"
		if major and tonumber(major) >= v then
			node_path = entry .. "/installation/bin/node"
			node_version = major .. "." .. minor .. "." .. patch
			break
		end
	end

	return node_path, node_version
end

-- write a function to get the node version from the path

return {
	"saghen/blink.cmp",
	-- Lazy load completion on insert mode
	event = "InsertEnter",
	-- optional: provides snippets for the snippet source
	dependencies = {
		"echasnovski/mini.snippets",
		-- { "rafamadriz/friendly-snippets", lazy = true },
		-- LuaSnip moved to optional - only load if using full profile
		"mgalliou/blink-cmp-tmux",
	},

	-- use a release tag to download pre-built binaries
	version = "1.*",
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
		-- 'super-tab' for mappings similar to vscode (tab to accept)
		-- 'enter' for enter to accept
		-- 'none' for no mappings
		--
		-- All presets have the following mappings:
		-- C-space: Open menu or open docs if already open
		-- C-n/C-p or Up/Down: Select next/previous item
		-- C-e: Hide menu
		-- C-k: Toggle signature help (if signature.enabled = true)
		--
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = { preset = "enter" },
		enabled = function()
			return not vim.list_contains(
					{ "DressingInput" },
					vim.bo.filetype
				)
				and vim.bo.buftype ~= "prompt"
				and vim.b.completion ~= false
		end,

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		-- (Default) Only show the documentation popup when manually triggered
		completion = {
			ghost_text = {
				enabled = false,
			},
			documentation = {
				treesitter_highlighting = false,
				auto_show = true,
			},
			list = {
				selection = {
					preselect = true,
					auto_insert = false,
				},
			},
			menu = {
				border = "solid",
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", gap = 1 },
						{ "source_name" },
					},
				},
			},
		},

		snippets = { preset = "mini_snippets" },

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			default = {
				-- "lazydev", -- Disabled for minimal config (plugin in optional)
				"lsp",
				"snippets",
				"path",
				"buffer",
				"tmux",
			},
			providers = {
				lsp = {
					score_offset = 10,
				},
				tmux = {
					name = "tmux",
					module = "blink-cmp-tmux",
					opts = {
						all_panes = true,
					},
				},
				snippets = {
					min_keyword_length = 2,
					score_offset = 4,
				},
				-- lazydev = {
				-- 	name = "LazyDev",
				-- 	module = "lazydev.integrations.blink",
				-- 	-- make lazydev completions top priority (see `:h blink.cmp`)
				-- 	score_offset = 100,
				-- }, -- Disabled for minimal config
			},
		},

		-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
		-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
		-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
		--
		-- See the fuzzy documentation for more information
		fuzzy = {
			implementation = "prefer_rust_with_warning",
		},
	},
	opts_extend = { "sources.default" },
	config = function(_, opts)
		require("blink.cmp").setup(opts)
	end,
}
