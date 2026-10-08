{
  description = "Marcel's Neovim Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
  }: let
    neovimTools = pkgs: pkgs-unstable:
      with pkgs; [
        # Core
        luajit
        lua54Packages.luarocks-nix
        lua51Packages.lua
        lua-language-server
        luarocks
        readline
        fzf
        fd
        ripgrep
        bat
        tree-sitter
        gcc
        python3Minimal

        # VSCode Language Servers (JSON, CSS, HTML, ESLint)
        vscode-langservers-extracted

        # LSP Servers
        astro-language-server
        bash-language-server
        clang-tools
        elixir-ls
        fennel-ls
        marksman
        markdown-oxide
        nil
        python3Packages.python-lsp-server
        python3Packages.pyflakes
        python3Packages.jedi
        python3Packages.mccabe
        python3Packages.pycodestyle
        rust-analyzer
        taplo
        typescript-language-server
        vtsls
        vale-ls
        mdx-language-server
        svelte-language-server
        qt6.qtdeclarative # qmlls
        ruff
        emmylua-ls # emmylua_ls

        # Formatters
        alejandra
        biome
        python3Packages.black
        cbfmt
        deno
        dprint
        eslint_d
        fixjson
        python3Packages.isort
        oxlint
        pkgs-unstable.oxfmt # not in nixos-25.11 yet
        prettier
        prettierd
        rumdl
        rustfmt
        shfmt
        emmylua-check
        stylua
        # tombi not available in nixpkgs
        xmlformat

        # Debuggers
        delve
        gdb
        vscode-extensions.vadimcn.vscode-lldb

        # CLI Tools
        lazygit
        tig
        gcc
        gnumake
        cargo
        direnv
        nodejs
        yarn
        podman
        difftastic
        diffutils
        tmux
        elixir
        util-linux
        coreutils
        curl
        bash
        findutils
        zoxide
      ];
  in
    {
      homeManagerModules.default = {
        config,
        lib,
        pkgs,
        ...
      }: {
        config = {
          programs.neovim = {
            enable = true;
            extraPackages = neovimTools pkgs (import nixpkgs-unstable {inherit (pkgs) system;});
            plugins = [
              pkgs.vimPlugins.nvim-treesitter.withAllGrammars
            ];
          };
          xdg.configFile."nvim".source = ./.;
          home.activation.clearNvimLuacCache =
            lib.hm.dag.entryAfter ["linkGeneration"] ''
              rm -rf "${config.xdg.cacheHome}/nvim/luac"
            '';
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        pkgs-unstable = import nixpkgs-unstable {inherit system;};
      in {
        devShells.default = pkgs.mkShell {
          packages = neovimTools pkgs pkgs-unstable;
          shellHook = ''
            echo "Lua shell on ${pkgs.luajit.version} – happy vim!"
          '';
        };
      }
    );
}
