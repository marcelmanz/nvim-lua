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
git clone git@github.com:marcelarie/nvim-lua ~/.config/marcelarie-nvim-lua
NVIM_APPNAME=marcelarie-nvim-lua/ nvim --headless +"Lazy! sync" +qa
```

Open Neovim with this config:

```bash
NVIM_APPNAME=marcelarie-nvim-lua/ nvim
```

## Plugin modes

This configuration supports two plugin modes for different performance needs:

### Core Mode (Default)

- fast startup
- ~14 essential plugins (33 counting deps)
- Basic editing, LSP, treesitter, and core capability
- **Startup time is less than 40ms**

### Full Mode

- a bit slower startup but still lazy loaded and fast
- 80+ plugins with extended functionality
- Includes all core plugins
- **Startup time around 160ms**

Switch between modes by setting the environment variable:

```bash
# Core mode (default)
NVIM_PROFILE=minimal nvim # or just `nvim`

# Full mode  
NVIM_PROFILE=full nvim
```

Or use the commands within Neovim:

- `:ProfileCurrent` - Show current mode
- `:ProfileMinimal` - Instructions for core mode
- `:ProfileFull` - Instructions for full mode

## Startup time

```bash
Startuptime: 41.23ms

LazyStart 16.07ms
LazyDone  30ms (+13.94ms)
UIEnter   41.23ms (+11.23ms)
```

## File Tree

```bash
    ┌─ install-neovim-latest.sh
 ┌─ scripts
 ├─ info.md
 ├─ dprint.json
 ├─ Dockerfile
 ├─ lazy-lock.json
 │  ┌─ options.lua
 │  ├─ zig-official-color.lua
 │  ├─ global.lua
 │  ├─ lsp-on-attach.lua
 │  ├─ treesitter-setup.lua
 │  ├─ tmux.lua
 │  ├─ keymaps.lua
 │  ├─ autocmd.lua
 │  ├─ sys-clip.lua
 │  │  ┌─ flash.lua
 │  │  ├─ apply-action.lua
 │  ├─ utils
 │  ├─ neovide.lua
 │  ├─ open_url.lua
 │  │  ┌─ persistend-qfl.lua
 │  │  ├─ update-fe-version.lua
 │  ├─ features
 │  ├─ lsp.lua
 │  ├─ ziggy.lua
 │  ├─ lsp-setup.lua
 │  │     ┌─ img-clip.lua
 │  │     ├─ git-conflict.lua
 │  │     ├─ blame.lua
 │  │     ├─ incline.lua
 │  │     ├─ cmp.lua
 │  │     ├─ mini-starter.lua
 │  │     ├─ hoversplit.lua
 │  │     ├─ ts-comments.lua
 │  │     ├─ timber.lua
 │  │     ├─ mason-null-ls.lua
 │  │     ├─ naysayer.lua
 │  │     ├─ luasnip.lua
 │  │     ├─ comment.lua
 │  │     ├─ buffer-manager.lua
 │  │     ├─ urlview.lua
 │  │     ├─ nvim-nu.lua
 │  │     ├─ mdx.lua
 │  │     ├─ lazydev.lua
 │  │     ├─ zk.lua
 │  │     ├─ vgit.lua
 │  │     ├─ dropbar.lua
 │  │     ├─ git-blame.lua
 │  │     ├─ code-companion.lua
 │  │     ├─ live-coding.lua
 │  │     ├─ hydra.lua
 │  │     ├─ flog.lua
 │  │     ├─ zen-mode.lua
 │  │     ├─ link-vim.lua
 │  │     ├─ no-clown-fiesta.lua
 │  │     ├─ rustaceanvim.lua
 │  │     ├─ fff.lua
 │  │     ├─ telekasten.lua
 │  │     ├─ colorbox.lua
 │  │     ├─ nvim-highlight-colors.lua
 │  │     ├─ markdown.lua
 │  │     ├─ fzf.lua
 │  │     ├─ watch.lua
 │  │     ├─ lsp-trouble.lua
 │  │     ├─ markdown-preview.lua
 │  │     ├─ easypick.lua
 │  │     ├─ tsc.lua
 │  │     ├─ debug.lua
 │  │     ├─ undotree.lua
 │  │     ├─ boo.lua
 │  │     ├─ snap.lua
 │  │     ├─ gh-preview.lua
 │  │     ├─ beam.lua
 │  │     ├─ kanagawa.lua
 │  │     ├─ footnote.lua
 │  │     ├─ venv-selector.lua
 │  │     ├─ mini-diff.lua
 │  │     ├─ harpoon.lua
 │  │     ├─ neoclip.lua
 │  │     ├─ mini-notify.lua
 │  │  ┌─ optional
 │  │  │  ┌─ conform.lua
 │  │  │  ├─ alpha.lua
 │  │  │  ├─ bamboo-colorscheme.lua
 │  │  │  ├─ nvim-surround.lua
 │  │  │  ├─ nvim-treesitter-context.lua
 │  │  │  ├─ substitute.lua
 │  │  │  ├─ mini-status.lua
 │  │  │  ├─ git-signs.lua
 │  │  │  ├─ todo-comments.lua
 │  │  │  ├─ everforest-colorscheme.lua
 │  │  │  ├─ session.lua
 │  │  │  ├─ oil.lua
 │  │  │  ├─ telescope.lua
 │  │  │  ├─ blink.lua
 │  │  │  ├─ ts-autotag.lua
 │  │  │  ├─ dart.lua
 │  │  │  ├─ colorschemes.lua
 │  │  │  ├─ copilot.lua
 │  │  ├─ core
 │  │  ├─ init.lua
 │  ├─ plugins
 │  ├─ color-settings.lua
 │  ├─ profiler.lua
 │  ├─ lazy-bootstrap.lua
 │  ├─ commands.lua
 │  ├─ plugin-profiles.lua
 │  ├─ lazy-plugins.lua
 ├─ lua
 │  ┌─ fennel.lua
 │  ├─ nil.lua
 │  ├─ md-oxide.lua
 │  ├─ bash.lua
 │  ├─ typescript.lua
 │  ├─ nix.lua
 │  ├─ markdown.lua
 │  ├─ tombi.lua
 │  ├─ python.lua
 │  ├─ rust-analyzer.lua
 │  ├─ json.lua
 │  ├─ lua.lua
 ├─ lsp
 │  ┌─ en.utf-8.add.spl
 │  ├─ en.utf-8.add
 ├─ spell
 ├─ README.md
 │  ┌─ ltex.hiddenFalsePositives.en-US.txt
 │  ├─ ltex.dictionary.en-US.txt
 ├─ ltex-dictionaries
 ├─ flake.nix
 ├─ flake.lock
 ├─ after
 ├─ startup.log
 │     ┌─ emoji.json
 │     ├─ math.json
 │     ├─ julia.json
 │     ├─ url_encoded.json
 │     ├─ latex.json
 │     ├─ gitmoji.json
 │     ├─ kaomoji.json
 │  ┌─ telescope-sources
 ├─ data
 ├─ init.lua
 ├─ stylua.toml
 nvim

13 directories, 131 files
```

Dependencies:

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [bat](https://githubn.com/sharkdp/bat)
