# Contributing guide

Contributions are more than welcome!

## Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).
Please make sure your commits/PR titles have appropriate prefixes
and scopes.

## Development

I use

- [`nix`](https://nixos.org/download.html#download-nix) for development and testing.
- [`stylua`](https://github.com/JohnnyMorganz/StyLua),
  [`.editorconfig`](https://editorconfig.org/),
  and [`alejandra`](https://github.com/kamadorueda/alejandra)
  for formatting.
- [`luacheck`](https://github.com/mpeterv/luacheck),
  and [`markdownlint`](https://github.com/DavidAnson/markdownlint),
  for linting.
- [`lua-language-server`](https://github.com/sumneko/lua-language-server/wiki/Diagnosis-Report#create-a-report)
  for static type checking.

### Type safety

Lua is incredibly responsive, giving immediate feedback for configuration.
But its dynamic typing makes Neovim plugins susceptible to unexpected bugs
at the wrong time.
To mitigate this, I rely on [LuaCATS annotations](https://luals.github.io/wiki/annotations/),
which are checked in CI.

### Running tests

This plugin uses [`busted`](https://lunarmodules.github.io/busted/) for testing.

The best way to run tests is with Nix (see below),
because this includes tests that take different
envrionments into account (e.g. with/without `rust-analyzer`, `cargo`, ...).

If you do not use Nix, you can run a basic version of the test suite using
`luarocks test`.
For more information, see the [neorocks tutorial](https://github.com/nvim-neorocks/neorocks#without-neolua).

### Vimdoc/tags

This project generates vim help pages from LuaCATS annotations
in certain Lua files.
Usually, this is relevant if you are making changes to the
plugin configuration API.
If CI fails because documentation needs to be generated,
you have two options:

- Enter a Nix devShell and run `pre-commit run --all-files`.
- Or, if you do not use Nix, I can merge and run it for you.

### Development using Nix

> **Note**
>
> [Flakes](https://nixos.wiki/wiki/Flakes) must be enabled.

To enter a development shell:

```console
nix develop
```

To apply formatting, while in a devShell, run

```console
pre-commit run --all
```

If you use [`direnv`](https://direnv.net/),
just run `direnv allow` and you will be dropped in this devShell.

To run tests locally

```console
nix build .#checks.<your-system>.haskell-tools-test --print-build-logs
```

For formatting and linting:

```console
nix build .#checks.<your-system>.formatting --print-build-logs
```

If you have flakes enabled and just want to run all checks that are available, run:

```console
nix flake check --print-build-logs
```
