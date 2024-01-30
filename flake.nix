{
  description = "A fork setup-less and lspconfig-free of rust-tools.nvim";

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

        mkTypeCheck = {
          rtp ? [],
          disabled-diagnostics ? [],
        }:
          pre-commit-hooks.lib.${system}.run {
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
                      library =
                        rtp
                        ++ (with pkgs.vimPlugins; [
                          "${nvim-dap}/lua"
                          "${toggleterm-nvim}/lua"
                          "${neotest}/lua"
                          "\${3rd}/busted/library"
                          "\${3rd}/luassert/library"
                        ]);
                      checkThirdParty = false;
                      ignoreDir = [
                        ".git"
                        ".github"
                        ".direnv"
                        "result"
                        "nix"
                        "doc"
                        "spec" # FIXME: busted library
                      ];
                    };
                    diagnostics = {
                      libraryFiles = "Disable";
                      disable = disabled-diagnostics;
                    };
                  };
                };
              };
            };
          };

        type-check-stable = mkTypeCheck {
          rtp = [
            "${pkgs.neovim}/share/nvim/runtime/lua"
            "${pkgs.neodev-plugin}/types/stable"
          ];
          disabled-diagnostics = [
            "undefined-doc-name"
            "redundant-parameter"
            "invisible"
          ];
        };

        type-check-nightly = mkTypeCheck {
          rtp = [
            "${pkgs.neovim-nightly}/share/nvim/runtime/lua"
            "${pkgs.neodev-plugin}/types/nightly"
          ];
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

        devShell = pkgs.nvim-nightly-tests.overrideAttrs (oa: {
          name = "rustaceanvim devShell";
          inherit (pre-commit-check) shellHook;
          buildInputs = with pre-commit-hooks.packages.${system};
            [
              alejandra
              lua-language-server
              stylua
              luacheck
              editorconfig-checker
              markdownlint-cli
            ]
            ++ oa.buildInputs;
        });

        docgen = pkgs.callPackage ./nix/docgen.nix {};
      in {
        devShells = {
          default = devShell;
          inherit devShell;
        };

        packages = rec {
          default = rustaceanvim;
          inherit docgen;
          inherit
            (pkgs)
            rustaceanvim
            nvim-minimal-stable
            nvim-minimal-nightly
            ;
        };

        checks = {
          formatting = pre-commit-check;
          inherit
            type-check-stable
            type-check-nightly
            ;
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
