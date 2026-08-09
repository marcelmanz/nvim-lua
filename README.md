<h2 align="center">Nvim config</h2>

<p align="left">
   Repo for personal use but if something doesn't work for you, feel free to open an <a href="https://github.com/marcelarie/nvim-lua/issues">issue</a>.
</p>

<div align="center">
  <img width="769.5" height="998" alt="nvim-start" src="https://github.com/user-attachments/assets/32676b7f-f2a5-4f5a-bf57-7c7e271523dd" />
</div>

## Install Instructions

> Install requires Neovim 0.11+. Always review the code before installing a configuration.

Clone the repository and install the plugins:

```bash
git clone git@github.com:marcelmanz/nvim-lua ~/.config/tm-nvim-lua
NVIM_APPNAME=tm-nvim-lua/ nvim --headless +"Lazy! sync" +qa
```

Open Neovim with this config:

```bash
NVIM_APPNAME=tm-nvim-lua/ nvim
```

## Startup time

```bash
Startuptime: 39.1ms

LazyStart 8.16ms
LazyDone  19.04ms (+10.88ms)
UIEnter   39.1ms (+20.05ms)
```

## File Tree

```bash
nvim/
├─ init.lua                        # entry point
├─ Makefile                        # format / lint targets
├─ flake.nix
├─ Dockerfile
├─ stylua.toml
├─ dprint.json
│
├─ lsp/                            # per-language LSP configs (vim.lsp.config)
│  ├─ astro.lua  bash.lua  c.lua
│  ├─ css.lua  elixir.lua  eslint.lua
│  ├─ fennel.lua  json.lua  lua.lua
│  ├─ markdown.lua  mdx.lua
│  ├─ nil.lua  nix.lua  python.lua
│  ├─ ruff.lua  rust.lua  svelte.lua
│  ├─ tailwindcss.lua  toml.lua  typescript.lua
│  └─ vale.lua
│
├─ lua/
│  ├─ config/                      # core neovim config
│  │  ├─ options.lua
│  │  ├─ keymaps.lua
│  │  ├─ keybind-helpers.lua
│  │  ├─ autocmds.lua
│  │  ├─ commands.lua
│  │  ├─ colors.lua
│  │  ├─ diagnostics.lua
│  │  └─ lazy.lua
│  │
│  ├─ lsp/                         # LSP orchestration
│  │  ├─ init.lua                  # enables servers via vim.lsp.enable
│  │  ├─ on-attach.lua
│  │  └─ hover.lua
│  │
│  ├─ plugins/                     # lazy.nvim plugin specs
│  │  ├─ blink.lua  conform.lua  fzf.lua
│  │  ├─ git-blame.lua  git-conflict.lua  git-signs.lua
│  │  ├─ hydra.lua  markdown.lua  mini.lua
│  │  ├─ nvim-highlight-colors.lua  nvim-treesitter-context.lua
│  │  ├─ oil.lua  session.lua  targets.lua
│  │  ├─ ts-autotag.lua  yanky.lua  ...
│  │
│  ├─ features/                    # editor features
│  │  ├─ diff.lua  incdec.lua  paste.lua
│  │  ├─ persistend-qfl.lua  vale-accept.lua
│  │  ├─ update-fe-version.lua
│  │  └─ runners/                  # language-specific code runners
│  │     ├─ bash.lua  c.lua  git.lua
│  │     ├─ just.lua  misc.lua  node.lua
│  │     ├─ rust.lua  test.lua
│  │
│  ├─ lib/                         # shared utility functions
│  │  ├─ init.lua  runner.lua  tmux.lua
│  │  ├─ flash.lua  open-url.lua  toggle-qf.lua
│  │  ├─ apply-action.lua  typescript.lua
│  │  └─ root-markers-with-field.lua
│  │
│  ├─ neovide.lua
│  ├─ profiler.lua
│  └─ treesitter-setup.lua
│
├─ snippets/                       # custom snippets
│  ├─ global.json  gitcommit.json
│  ├─ markdown.json  python.json  typescript.json
│
├─ after/queries/                  # treesitter query overrides
│  ├─ markdown/
│  └─ markdown_inline/
│
└─ scripts/
   └─ install-neovim-latest.sh
```

Dependencies:

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [bat](https://githubn.com/sharkdp/bat)
