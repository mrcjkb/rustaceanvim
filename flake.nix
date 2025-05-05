{
  description = "A fork setup-less and lspconfig-free of rust-tools.nvim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neorocks = {
      url = "github:nvim-neorocks/neorocks";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };

    gen-luarc = {
      url = "github:mrcjkb/nix-gen-luarc-json";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
      };
    };

    vimcats = {
      url = "github:mrcjkb/vimcats";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    git-hooks,
    neorocks,
    gen-luarc,
    vimcats,
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
      imports = [
        git-hooks.flakeModule
      ];
      perSystem = {
        config,
        system,
        pkgs,
        ...
      }: let
        ci-overlay = import ./nix/ci-overlay.nix {
          inherit self;
          plugin-name = name;
        };

        luarc-plugins = with pkgs.lua51Packages;
          [
            nvim-nio
          ]
          ++ (with pkgs.vimPlugins; [
            neotest
            nvim-dap
          ]);

        luarc-nightly = pkgs.mk-luarc {
          nvim = pkgs.neovim-nightly;
          plugins = luarc-plugins;
        };

        luarc-stable = pkgs.mk-luarc {
          nvim = pkgs.neovim-unwrapped;
          plugins = luarc-plugins;
          disabled-diagnostics = [
            "undefined-doc-name"
            "undefined-doc-class"
            "redundant-parameter"
            "invisible"
          ];
        };

        type-check-nightly = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            lua-ls = {
              enable = true;
              settings.configuration = luarc-nightly;
            };
          };
        };

        type-check-stable = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            lua-ls = {
              enable = true;
              settings = {
                configuration = luarc-stable;
              };
            };
          };
        };

        pre-commit-check = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            statix.enable = true;
            alejandra.enable = true;
            stylua.enable = true;
            luacheck.enable = true;
            editorconfig-checker.enable = true;
            markdownlint.enable = true;
            docgen = {
              enable = true;
              name = "docgen";
              entry = "${docgen}/bin/docgen";
              files = "\\.(lua)$";
              pass_filenames = false;
            };
            doctags = {
              enable = true;
              name = "doctags";
              entry = "${pkgs.neovim-unwrapped}/bin/nvim -c 'helptags doc' +q";
              files = "\\.(txt)$";
              pass_filenames = false;
            };
          };
        };

        devShell = pkgs.nvim-nightly-tests.overrideAttrs (oa: {
          name = "rustaceanvim devShell";
          shellHook = ''
            ${config.pre-commit.installationScript}
            ln -fs ${pkgs.luarc-to-json luarc-nightly} .luarc.json
          '';
          buildInputs = with git-hooks.packages.${system};
            [
              pkgs.statix
              pkgs.nixd
              alejandra
              lua-language-server
              stylua
              luacheck
              editorconfig-checker
              markdownlint-cli
              docgen
            ]
            ++ oa.buildInputs;
          doCheck = false;
        });

        docgen = pkgs.callPackage ./nix/docgen.nix {inherit vimcats;};
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ci-overlay
            neorocks.overlays.default
            gen-luarc.overlays.default
            plugin-overlay
          ];
        };
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
            codelldb
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
