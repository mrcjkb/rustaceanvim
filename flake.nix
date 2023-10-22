{
  description = "A fork of rust-tools.nvim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
    };

    neorocks = {
      url = "github:nvim-neorocks/neorocks";
    };

    neodev-nvim = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    pre-commit-hooks,
    neorocks,
    neodev-nvim,
    ...
  }: let
    name = "rustaceanvim";

    plugin-overlay = import ./nix/plugin-overlay.nix {
      inherit name self;
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        system,
        ...
      }: let
        ci-overlay = import ./nix/ci-overlay.nix {
          inherit
            self
            neodev-nvim
            ;
          plugin-name = name;
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ci-overlay
            neorocks.overlays.default
            plugin-overlay
          ];
        };

        type-check = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            lua-ls.enable = true;
          };
          settings = {
            lua-ls = {
              config = {
                runtime.version = "LuaJIT";
                Lua = {
                  workspace = {
                    library = [
                      "${pkgs.neovim-nightly}/share/nvim/runtime/lua"
                      "${pkgs.neodev-plugin}/types/nightly"
                      # "${pkgs.luajitPackages.busted}"
                    ];
                    checkThirdParty = false;
                    ignoreDir = [
                      ".git"
                      ".github"
                      ".direnv"
                      "result"
                      "nix"
                      "doc"
                      "spec" # FIXME: Add busted library
                    ];
                  };
                  diagnostics. libraryFiles = "Disable";
                };
              };
            };
          };
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            alejandra.enable = true;
            stylua.enable = true;
            luacheck.enable = true;
            editorconfig-checker.enable = true;
            markdownlint.enable = true;
          };
        };

        devShell = pkgs.mkShell {
          name = "rustaceanvim devShell";
          inherit (pre-commit-check) shellHook;
          buildInputs = with pre-commit-hooks.packages.${system}; [
            alejandra
            lua-language-server
            stylua
            luacheck
            editorconfig-checker
            markdownlint-cli
          ];
        };

        docgen = pkgs.callPackage ./nix/docgen.nix {};
      in {
        devShells = {
          default = devShell;
          inherit devShell;
        };

        packages = let
          rustaceanvim-nvim = pkgs.rustaceanvim-nvim;
        in {
          default = rustaceanvim-nvim;
          inherit
            rustaceanvim-nvim
            docgen
            ;
        };

        checks = {
          formatting = pre-commit-check;
          inherit type-check;
          inherit
            (pkgs)
            nvim-stable-tests
            nvim-nightly-tests
            ;
        };
      };
      flake = {
        overlays.default = plugin-overlay;
      };
    };
}
