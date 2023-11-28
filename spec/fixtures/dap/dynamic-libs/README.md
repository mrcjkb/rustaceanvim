# DAP/dynamic linking

A dynamic linking test project for rustaceanvim.

Use with Nix (flakes enabled):

```shell
nix develop
```

(depends on [nixpkgs/#264887](https://github.com/NixOS/nixpkgs/pull/264887).

Windows use will require:

```shell
cargo install -f cargo-binutils
rustup component add llvm-tools-preview
```

To let `cargo` use LLD's linker.
See [The bevy docs](https://bevyengine.org/learn/book/getting-started/setup/).
