<!-- markdownlint-disable -->
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.2.0] - 2023-10-29

### Added
- Completions for `:RustLsp` subcommands' arguments.

### Changed
- Removed `plenary.nvim` dependency (`dap` and `quickfix` executor).
  This plugin now has no `plenary.nvim` dependencies left.
  NOTE: As this does **not** lead to a bump in the minimal requirements,
  this is not a breaking change.

## [3.1.1] - 2023-10-28

### Fixed
- Remove accidental use of Neovim nightly API (`dap`, `crateGraph`, `explainError`) [[#26](https://github.com/mrcjkb/rustaceanvim/issues/26)].
- Add static type checking for Neovim stable API.

## [3.1.0] - 2023-10-28

### Added
- `:RustLsp explainError` command, uses `rustc --explain` on error diagnostics with
  an error code.
- `:RustLsp rebuildProcMacros` command.

### Fixed
- Health check got stuck if `lldb-vscode` was installed.

## [3.0.4] - 2023-10-25

### Fixed
- Allow `:RustLsp hover range` to accept a range.
- Fix `:RustLsp crateGraph` passing arguments as list.

## [3.0.3] - 2023-10-25

### Fixed
- Potential attempt to index `nil` upvalue when sending `workspace/didChangeWorkspaceFolders`
  to LSP server [[#22](https://github.com/mrcjkb/rustaceanvim/issues/22)].

## [3.0.2] - 2023-10-23

### Fixed
- Hover actions: Tree-sitter syntax highlighting 
  in Neovim 0.9 [[#20](https://github.com/mrcjkb/rustaceanvim/issues/20)].

## [3.0.1] - 2023-10-23

### Fixed
- Add support for `workspace/didChangeWorkspaceFolders` to prevent more than one
  rust-analyzer server from spawning per Neovim instance [[#7](https://github.com/mrcjkb/rustaceanvim/issues/7)].
- Neovim 0.9 compatibility [[#9](https://github.com/mrcjkb/rustaceanvim/issues/9)].

## [3.0.0] - 2023-10-22

### Changed
- Renamed this plugin to `rustaceanvim`,
  to avoid potential clashes with [`vxpm/ferris.nvim`](https://github.com/vxpm/ferris.nvim),
  `vxpm/ferris.nvim` was created just before I renamed my fork
  (but after I had checked the web for name clashes (╯°□°)╯︵ ┻━┻).

## [2.1.1] - 2023-10-22

### Fixed
- Open external docs: Use `xdg-open` or `open` (MacOS) by default
  and fall back to `netrw`.
  Remove redundant URL encoding.

## [2.1.0] - 2023-10-22

### Added

- Add a `vim.g.rustaceanvim.server.auto_attach` option, which
  can be a `boolean` or a `fun():boolean` that determines
  whether or not to auto-attach the LSP client when opening
  a Rust file.

### Fixed

- [Internal] Type safety in `RustLsp` command construction.
  This fixes a type error in the `hover` command validation.
- Failure to start on standalone files if `cargo` is not installed.

## [2.0.0] - 2023-10-21

### Breaking changes
- Don't pollute the command space:
  Use a single command with subcommands and completions.
  - `RustAnalyzer [start|stop]` 
    (always available in Rust projects)
  - `RustLsp [subcommand]` 
    (available when the LSP client is running)
    e.g. `RustLsp moveItem [up|down]`

## [1.0.1] - 2023-10-21

### Fixed
- Hover actions + command cache: module requires.

## [1.0.0] - 2023-10-21

### Added
- Initial release of `rustaceanvim`.
- `:RustSyntaxTree` and `:RustFlyCheck` commands.
- `:RustAnalyzerStart` and `:RustAnalyzerStop` commands.
- Config validation.
- Health checks (`:checkhealth rustaceanvim`).
- Vimdocs (auto-generated from Lua docs - `:help rustaceanvim`).
- Nix flake.
- Allow `tools.executor` to be a string.
- LuaRocks releases.
- Minimal config for troubleshooting.

### Internal
- Added type annotations.
- Nix CI and linting infrastructure and static type checking.
- Lazy load command modules.

### Fixed
- Numerous potential bugs encountered during rewrite.
- Erroneous semantic token highlights.
- Make sure we only send LSP requests to the correct client.

### Breaking changes compared to `rust-tools.nvim`
- [Removed the `setup` function](https://mrcjkb.dev/posts/2023-08-22-setup.html) and revamped the architecture
  to be less prone to type errors.
  This plugin is a filetype plugin and works out of the box.
  The default configuration should work for most people,
  but it can be configured with a `vim.g.rustaceanvim` table.
- Removed the `lspconfig` dependency.
  This plugin now uses the built-in LSP client API.
  You can use `:RustAnalyzerStart` and `:RustAnalyzerStop`
  to manually start/stop the LSP client.
  This plugin auto-starts the client when opening a rust file,
  if the `rust-analyzer` binary is found.
- Removed `rt = require('rust-tools')` table.
  You can access the commands using Neovim's `vim.cmd` Lua bridge,
  for example `:lua vim.cmd.RustSSR()` or `:RustSSR`.
- Bumped minimum Neovim version to `0.9`.
- Removed inlay hints, as this feature will be built into Neovim `0.10`.
