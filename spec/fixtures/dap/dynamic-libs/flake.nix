{
  description = "devShell for Rust projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    fenix,
    ...
  }:
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
        pkgs,
        system,
        ...
      }: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            fenix.overlays.default
          ];
        };
      in {
        devShells.default = pkgs.mkShell {
          name = "rust devShell";
          buildInputs = with pkgs;
          with pkgs; [
            fenix.packages.${system}.default.toolchain
            rust-analyzer-nightly
            clang
            llvm
            llvmPackages.bintools
            pkg-config
            alsa-lib
            systemd
          ];
        };
      };
    };
}
