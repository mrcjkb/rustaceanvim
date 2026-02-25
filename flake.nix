{
  description = "Supercharge your Rust experience in Neovim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

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
        system,
        pkgs,
        ...
      }: let
        neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.default;

        ci-overlay = import ./nix/ci-overlay.nix {inherit neovim-nightly;};

        pre-commit-check = git-hooks.lib.${system}.run {
          src = self;
          hooks = {
            statix.enable = true;
            alejandra.enable = true;
            stylua.enable = true;
            luacheck.enable = true;
            # editorconfig-checker.enable = true;
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
              entry = "${pkgs.neovim-unwrapped}/bin/nvim -u NONE -c 'helptags doc' +q";
              files = "\\.(txt)$";
              pass_filenames = false;
            };
          };
        };

        devShell = pkgs.mkShell {
          name = "rustaceanvim devShell";
          shellHook = ''
            ${pre-commit-check.shellHook}
          '';
          env = {
            EMMYLUALS_CONFIG = ".luarc.json";
          };
          buildInputs = with git-hooks.packages.${system}; [
            pkgs.lux-cli
            pkgs.statix
            pkgs.nixd
            pkgs.emmylua-ls
            alejandra
            stylua
            editorconfig-checker
            markdownlint-cli
            docgen
          ];
        };

        docgen = pkgs.callPackage ./nix/docgen.nix {inherit vimcats;};
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ci-overlay
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
        };
      };
      flake = {
        overlays.default = plugin-overlay;
      };
    };
}
