{
  description = "Marcel's Neovim Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    neovimTools = pkgs:
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
        vale-ls
        mdx-language-server

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
        prettier
        prettierd
        rustfmt
        shfmt
        emmylua-check
        stylua
        # tombi not available in nixpkgs
        xmlformat

        # Debuggers
        delve
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
        docker
        difftastic
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
            extraPackages = neovimTools pkgs;
            plugins = [
              pkgs.vimPlugins.nvim-treesitter.withAllGrammars
            ];
          };
          xdg.configFile."nvim".source = ./.;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        devShells.default = pkgs.mkShell {
          packages = neovimTools pkgs;
          shellHook = ''
            echo "Lua shell on ${pkgs.luajit.version} – happy vim!"
          '';
        };
      }
    );
}
