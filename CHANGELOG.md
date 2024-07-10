<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.26.1] - 2024-07-10

### Fixed

- DAP: rust-analyzer [removed the `cargoExtraArgs` field](https://github.com/rust-lang/rust-analyzer/pull/17547),
  which is a breaking change.

## [4.26.0] - 2024-07-07

### Added

- LSP: Added optional `current`/`cycle` arguments to
  the `explainError` and `renderDiagnostic` commands.
  No argument defaults to `cycle`, which is current base behaviour. `current`
  makes these functions only look for diagnostics in current cursor line
  Thanks [@Rumi152](https://github.com/Rumi152)!

### Fixed

## [4.25.1] - 2024-06-21

### Changed

- Testables: Default to `termopen` test executor if not using `neotest`

### Added

### Fixed

- LSP: Support completions for `RustLsp` with selection ranges.

## [4.25.0] - 2024-06-16

### Added

- LSP: If Neovim's file watcher is disabled, configure rust-analyzer
  to enable server-side file watching, unless it has been configured
  otherwise [[#423](https://github.com/mrcjkb/rustaceanvim/issues/423)].

### Fixed

- DAP: Dynamic library path setup using nightly rust builds
  (stable `rustc` was always used due to a missing `cwd` parameter).
  Thanks [@morfnasilu](https://github.com/morfnasilu)!
- DAP: Dynamic linking on macOS not working due to a typo in the
  `DYLD_LIBRARY_PATH` environment variable.
  Thanks [@morfnasilu](https://github.com/morfnasilu)!

## [4.24.1] - 2024-06-15

### Fixed

- Don't set deprecated `allFeatures` setting by default.
  Thanks [@zjp-CN](https://github.com/zjp-CN)!
- Error when decoding invalid JSON or blank string from cargo metadata.

## [4.24.0] - 2024-05-30

### Added

- Config: Add a new `config.server.root_dir` option to override the root
  directory detection logic
  Thanks [@bgw](https://github.com/bgw)!

### Fixed

- LSP: Force-extend Neovim's default client capabilities
  with detected plugin capabilities, to ensure plugin capability
  extensions take precedence in case of conflict.

## [4.23.5] - 2024-05-24

### Fixed

- LSP: Bug preventing rustaceanvim from loading `rust-analyzer.json` settings
  if there's no `"rust-analyzer":` key.

## [4.23.4] - 2024-05-23

### Fixed

- LSP: Error when editing a rust file in a directory
  that does not exist [(#404)](https://github.com/mrcjkb/rustaceanvim/issues/404).

## [4.23.3] - 2024-05-23

### Fixed

- LSP/Clippy: use correct rust-analyzer config key, `check` instead
  of `checkOnSave`, to enable clippy if detected.
  Thanks [@Ryex](https://github.com/Ryex)!

## [4.23.2] - 2024-05-16

### Fixed

- Executors/termopen:
 `<Esc>` to close buffer not silent.
  Thanks [@b1nhack](https://github.com/b1nhack)!
- LSP: Only register `completionItem.snippetSupport` client capability
  when using Neovim >= 0.10.

## [4.23.1] - 2024-05-12

### Fixed

- UI/Config: Don't override Neovim defaults in default `float_win_config`.

## [4.23.0] - 2024-05-11

### Added

- Config: Open vertical splits from floating windows with
  `tools.float_win_config.open_split = 'vertical'`.
  Thanks [@dwtong](https://github.com/dwtong)!

## [4.22.10] - 2024-05-04

### Fixed

- Neotest: Remove unsupported `--show-output` flag when running
  with cargo-nextest.

## [4.22.9] - 2024-05-04

### Changed

- Update neovim nightly API call.
  If you are using neovim nightly, you need a build after May 04, 2024.
  Thanks [@NicolasGB](https://github.com/NicolasGB)!

## [4.22.8] - 2024-04-26

### Fixed

- LSP: Reuse client when viewing git dependencies [[#374)](https://github.com/mrcjkb/rustaceanvim/issues/373)].
  Thanks [@eero-lehtinen](https://github.com/eero-lehtinen)!

## [4.22.7] - 2024-04-26

### Fixed

- LSP: `renderDiagnostic` and `explainError` skipped diagnostics
  if they were in the same location
  as other diagnostics.
  Thanks [@LukeFranceschini](https://github.com/LukeFranceschini)!
- LSP: `renderDiagnostic` and `explainError` stopped searching early
  and defaulted to the first
  diagnostic in the file,
  instead of the next diagnostic after the current cursor position.
  Thanks [@LukeFranceschini](https://github.com/LukeFranceschini)!

## [4.22.6] - 2024-04-19

### Changed

- Update neovim nightly API call [[#365](https://github.com/mrcjkb/rustaceanvim/issues/365)].
  If you are using neovim nightly, you need a build after April 19, 2024.

## [4.22.5] - 2024-04-18

### Fixed

- UI: `float_win_config.border` not applied
  to code action group windows [[#363](https://github.com/mrcjkb/rustaceanvim/issues/363)].

## [4.22.4] - 2024-04-15

### Fixed

- Neotest: Replace nightly API call with Neovim 0.9 API call
  (introduced in 4.22.1).

## [4.22.3] - 2024-04-14

### Fixed

- Neotest: No tests found when getting root directory for a project directory.

## [4.22.2] - 2024-04-14

### Fixed

- Neotest/DAP: Undo sanitize command for debugging when running with
  a non-dap strategy, in case it was sanitized during a dap strategy run.

## [4.22.1] - 2024-04-14

### Fixed

- Neotest/DAP: multiple `--no-run` flags added to command when debugging
  multiple times [[#357](https://github.com/mrcjkb/rustaceanvim/issues/357)].

## [4.22.0] - 2024-04-14

### Added

- Config: Customise group action icon with `tools.code_actions.group_icon`.
  Thanks [@ColdMacaroni](https://github.com/ColdMacaroni)!

## [4.21.2] - 2024-04-13

### Fixed

- Health: Report error if version check fails for a required
  external dependency. This should help with false positives
  when detecting `rust-analyzer` if the rustup wrapper is installed,
  but `rust-analyzer` isn't.

## [4.21.1] - 2024-04-11

### Fixed

- LSP: `renderDiagnostic` doesn't move cursor if it falls back to the
  first diagnostic when searching forwards.

## [4.21.0] - 2024-04-01

### Added

- LSP: Support structural search and replace (SSR)
  just for the selected range.

## [4.20.0] - 2024-04-01

### Added

- DAP/LSP: `tools.cargo_override` option to
  override the `cargo` command for runnables/debuggables/testables.

## [4.19.0] - 2024-04-01

### Added

- DAP/LSP: `RustLsp [run|debug]` commands for running/debugging targets
  at the current cursor position.
- LSP: Join multiple visually selected lines with `:RustLsp joinLines`.

### Fixed

- LSP: Escape character inserted before `}` when applying code action
  with `SnippetTextEdit` [[#303](https://github.com/mrcjkb/rustaceanvim/issues/303)].

## [4.18.2] - 2024-03-28

### Changed

- DAP: Output command that was run if debug build
  compilation fails.

## [4.18.1] - 2024-03-28

### Fixed

- DAP: Add both `stderr` and `stdout` to error message
  if debug build compilation fails.

## [4.18.0] - 2024-03-27

### Added

- `:RustLsp openDocs` command [[#325](https://github.com/mrcjkb/rustaceanvim/issues/325)].

## [4.17.0] - 2024-03-26

### Added

- LSP: Automatically detect and register client capabilities for the following plugins,
  if installed:
  - [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
  - [nvim-lsp-selection-range](https://github.com/camilledejoye/nvim-lsp-selection-range)
  - [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)

### Fixed

- Neotest: Correctly mark passed and skipped tests when running a
  whole test file or module [[#321](https://github.com/mrcjkb/rustaceanvim/issues/321)].
- DAP: Only load `.vscode/launch.json` configurations that don't conflict
  with the configured adapter type.

## [4.16.0] - 2024-03-24

### Added

- Initialization: Warn if nvim-lspconfig.rust-analyzer setup is detected.

## [4.15.0] - 2024-03-24

### Added

- LSP: `RustAnalyzer reloadSettings` command to reload settings without restarting
  [[#309](https://github.com/mrcjkb/rustaceanvim/pull/309)].
  Thanks [@GuillaumeLagrange](https://github.com/GuillaumeLagrange)!

### Fixed

- DAP: Defer automatic registration of nvim-dap configurations on LSP client init,
  to improve reliability.

## [4.14.1] - 2024-03-17

### Fixed

- Health: rust-analyzer reported as not found in neovim 0.9 [[#302](https://github.com/mrcjkb/rustaceanvim/issues/302)].

## [4.14.0] - 2024-03-17

### Added

- [Experimental] Load rust-analyzer settings from `.vscode/settings.json`.
  Can be enabled by setting `vim.g.rustaceanvim.server.load_vscode_settings`
  to `true` [[#286](https://github.com/mrcjkb/rustaceanvim/issues/286)].
- Health: Detect rust-analyzer wrapper without rust-analyzer (Neovim >= 0.10).

### Fixed

- Config: Don't validate configs whose types are defined in external APIs
  such as nvim-dap [[#294](https://github.com/mrcjkb/rustaceanvim/issues/294)].
- DAP: Don't error if adding source/library information fails (warn instead).
- LSP/DAP: Fail silently if adding DAP configurations
  on LSP client attach fails [[#295](https://github.com/mrcjkb/rustaceanvim/issues/295)].

## [4.13.0] - 2024-03-15

### Added

- LSP: More flexibility when overriding default rust-analyzer settings.
  The `server.settings` function can now take a `default_settings` tabe
  to be merged.

### Fixed

- Loading settings from `rust-analyzer.json`:
  Potential for duplicate lua config keys if json keys are of the format:
  `"rust-analyzer.foo.bar"`

## [4.12.2] - 2024-03-11

### Fixed

- LSP/Windows: path normalisation preventing lsp from working
  `textDocument/definition` to std library [[#285](https://github.com/mrcjkb/rustaceanvim/pull/285)].
  Thanks [@tangtang95](https://github.com/tangtang95)!

## [4.12.1] - 2024-03-09

### Fixed

- UI: Buggy concealing of elements in rendered diagnostics [[#280](https://github.com/mrcjkb/rustaceanvim/issues/280)].
- LSP: Use file directory name as cwd when getting cargo metadata.
  This prevents rustaceanvim from detecting the wrong project root
  in standalone files if the current cwd is a cargo project.

## [4.12.0] - 2024-03-08

### Fixed

- DAP: `:RustLsp! debuggables` not falling back to UI select
  when no debuggable is found.

### Added

- LSP: Support falling back to UI select for `:RustLsp! runnables`
  and `:RustLsp! testables`.

## [4.11.1] - 2024-03-04

### Fixed

- LSP/Windows: Windows path normalisation preventing LSP client
  from working [[#273](https://github.com/mrcjkb/rustaceanvim/issues/273)].

## [4.11.0] - 2024-03-03

### Added

- LSP: By default, don't auto-attach to buffers that aren't files [[#268](https://github.com/mrcjkb/rustaceanvim/issues/268)].

### Fixed

- LSP: Bug preventing reload workspace on save Cargo.toml
  when opening another Rust buffer [[#270](https://github.com/mrcjkb/rustaceanvim/issues/270)].
- LSP: Don't try to delete `RustLsp` command on client exit
  if it doesn't exist, and fail silently.

## [4.10.2] - 2024-03-01

### Fixed

- LSP: Schedule Neovim API calls on `on_exit` [[#267](https://github.com/mrcjkb/rustaceanvim/pull/267)].
  Thanks [@tomtomjhj](https://github.com/tomtomjhj)!

## [4.10.1] - 2024-02-27

### Fixed

- UI: Explicitly disable signcolumn for grouped code action
  and hover action windows [[#262](https://github.com/mrcjkb/rustaceanvim/issues/262)].

## [4.10.0] - 2024-02-23

### Added

- LSP/Grouped code actions: Add `<ESC>` keymap to close buffer.
  This is consistent with the behaviour of the hover actions buffer.

## [4.9.0] - 2024-02-23

### Added

- Nix: `codelldb` adapter package (without the vscode extension)
  as a nixpkgs overlay and a flake output.

### Reverted

- Don't run `ftplugin/rust.lua` more than once on the same
  buffer.
  This prevented the client from reattaching when running
  `:e` on a buffer [[#250](https://github.com/mrcjkb/rustaceanvim/issues/250)].

## [4.8.0] - 2024-02-20

### Added

- Neotest: Expose doctests in `:Neotest summary` window [[#247](https://github.com/mrcjkb/rustaceanvim/pull/247)].
  Thanks [@bltavares](https://github.com/bltavares)!

### Fixed

- Testables: Run doctests when cargo-nextest is present [[#246](https://github.com/mrcjkb/rustaceanvim/pull/246)]
  Thanks [@bltavares](https://github.com/bltavares)!
- Windows: Normalize file actions when comparing to root dir [[#245](https://github.com/mrcjkb/rustaceanvim/pull/245)].
  Thanks [@bltavares](https://github.com/bltavares)!

## [4.7.5] - 2024-02-20

### Fixed

- DAP: Use deep copies of dap configs.
- DAP: Bad config validation: `dap.configuration.env` should be
  a `table`, not a `string`.

## [4.7.4] - 2024-02-19

### Fixed

- LSP: Support both top-level rust-analyzer object and object with
  `"rust-analyzer":` key when importing settings from `rust-analyzer.json`.
  The fix introduced in version 4.6.0 had accidentally broken
  backward compatibility. The new implementation is backward compatible again.

## [4.7.3] - 2024-02-15

### Fixed

- LSP: Error when running `reloadWorkspace`,
  `rebuildMacros` or `workspaceSymbol` from a non-rust buffer [[#234](https://github.com/mrcjkb/rustaceanvim/issues/234)].
- Internal: Don't pass client not found error to handler.

## [4.7.2] - 2024-02-13

### Revert

- DAP(`codelldb`): Redirect `stdio` (`stdout`) to a temp file.

## [4.7.1] - 2024-02-12

### Fixed

- LSP: `checkOnSave = false` not respected when clippy is installed
  (introduced with clippy auto-detection in version `4.6.0`).

## [4.7.0] - 2024-02-11

### Added

- Testables: Add `tools.crate_test_executor` option for running
  crate test suites (`--all-targets`).
- Rustc: Do not require a main function,
  and support the 2024 edition
  via `unstable-options`.
  Thanks [@saying121](https://github.com/saying121)!

### Fixed

- Neotest: Nested modules + position updates when switching buffers [[#223](https://github.com/mrcjkb/rustaceanvim/pull/223)].
  Thanks [@jameshurst](https://github.com/jameshurst)!
- Testables: Support `neotest` executor when using `nextest`.
- Testables: Support aliases for `test_executor` and `crate_test_executor`.

## [4.6.0] - 2024-02-07

### Added

- LSP: New `tools.enable_clippy` option (defaults to `true`).
  Enable clippy lints on save if a `cargo-clippy` installation
  is detected.

### Fixed

- testables/neotest: Don't use nextest if disabled in the config.
- LSP: load project-local rust-analyzer.json configs into
 `server['rust-analyzer']`, instead of replacing the `server` config.

## [4.5.2] - 2024-02-06

### Fixed

- runnables/debuggables/testables: `cd` into directory with spaces [[#212](https://github.com/mrcjkb/rustaceanvim/issues/212)].

### Fixed

## [4.5.1] - 2024-02-03

### Fixed

- LSP: Notify if an LSP request was made but no rust-analyzer client is attached.
- Neotest: Only the current buffer was queried for test positions.

## [4.5.0] - 2024-02-02

### Added

- Filtered workspace symbol searches with
  `:RustLsp[!] workspaceSymbol [onlyTypes?|allSymbols?] [query?]`.
  Will include dependencies if called with a bang `!`.
- Neotest: Basic support for `require('neotest').run.run { suite = true }`.
  This will run the current crate's test suite, if detected.
  Note that positions are still only discovered for buffers with an attached
  LSP client.

## [4.4.0] - 2024-02-01

### Added

- You can now register a `rustaceanvim.neotest` adapter with [neotest](https://github.com/nvim-neotest/neotest).
  It will query rust-analyzer for test positions and test commands in any
  buffer to which the LSP client is attached.
  If you do so, `tools.test_executor` will default to a new `'neotest'`
  executor, which will use neotest to run `testables` or `runnables` that are tests.
- Support for `require('neotest').run.run { strategy = 'dap' }`.
  This will use the same logic as `:RustLsp debuggables` to set neotest's
  DAP strategy. No extra configuration needed!
- `:RustLsp testables`: Prettier selection options.

### Fixes

- DAP(`codelldb`): Redirect `stdio` (`stdout`) to a temp file.

## [4.3.0] - 2024-01-31

### Changed

- LSP: Improved parsing of test result failure messages.

## [4.2.1] - 2024-01-30

### Fixed

- LSP: Only advertise `rust-analyzer.debugSingle` command capability
  if nvim-dap is installed.
- LSP: `nil` error if running `:RustLsp! testables` and there is no
  previous testable.
- LSP: Update previous testables cache if executing a `rust-analyzer.runSingle`
  command that is a test.

## [4.2.0] - 2024-01-30

### Added

- Config: Separate `tools.executor` and `tools.test_executor` options.
  The `test_executor` is used for test runnables (e.g. `cargo test`).
- LSP: New test executor, `'background'` that runs tests in the background
  and provides diagnostics for failed tests when complete.
  Used by default in Neovim >= 0.10.
- LSP: `:RustLsp testables` command, which is equivalent
  to `:RustLsp runnables`, but filters the runnables for tests only,

> [!IMPORTANT]
>
> In Neovim < 0.10, `'background'` executor blocks the UI while running tests.

## [4.1.0] - 2024-01-29

### Added

- `:Rustc unpretty` command:
  Use `rustc -Z unpretty=[mir|hir|...]` to inspect mir and other things,
  and achieve an experience similar to Rust Playground.
  (currently requires a nightly compiler).
  Thanks [saying121](https://github.com/saying121)!
- Config: `tools.rustc` arguments for `rustc`.

### Changed

- Improved command completions.
  - Filter suggested subcommand arguments based on existing user input.
  - When calling, `:RustLsp!`, show only subcommands that change
    behaviour with a bang.

### Fixed

- Command completions: Removed completions
  for `runnables/debuggables last`.

## [4.0.3] - 2024-01-28

### Fixed

- `renderDiagnostic`: Window closes immediately if `auto_focus`
  is disabled [[#193](https://github.com/mrcjkb/rustaceanvim/issues/193)].
- `explainError`/`renderDiagnostic`: Fall back to first
  detected diagnostic if none is found close to the cursor.

## [4.0.2] - 2024-01-27

### Fixed

- LSP (standalone): Use `bufnr` passed into `lsp.start` function when
  determining detached file name.

## [4.0.1] - 2024-01-27

### Fixed

- LSP: Fix resetting client state on `:RustAnalyzer stop`
  if only one client is attached.

### Performance

- Only setup `vim.lsp.commands` for rust-analyzer on the first
  initialization.
- Don't run `ftplugin/rust.lua` more than once on the same
  buffer.

## [4.0.0] - 2024-01-25

### BREAKING CHANGES

- To run the previous runnable/debuggable, you would call `:RustLsp runnables last`
  or `:RustLsp debuggables last`.
  These two functions now take optional arguments that you can pass to the executables.
  The new way to run the previous runnable/debuggable is with a bang (`!`).
  e.g. `:RustLsp! debuggables`.
  In Lua, this is `vim.cmd.RustLsp { 'debuggables', bang = true }`, and the same
  for `'runnables'`.

### Added

- LSP: Option to fall back to `vim.ui.select` if there
  are no code action groups when running `:RustLsp codeAction`.
- LSP/DAP: Allow overriding executable args with
  `:RustLsp runnables args[]` and `:RustLsp debuggables args[]`.

### Fixed

- LSP: Focus lost when secondary float opens on `:RustLsp codeAction` [[#169](https://github.com/mrcjkb/rustaceanvim/issues/169)].

## [3.17.3] - 2024-01-25

### Fixed

- DAP: `nil` safety in standalone files [[#182](https://github.com/mrcjkb/rustaceanvim/issues/182)].

## [3.17.2] - 2024-01-22

### Fixed

- LSP: Properly sanitize hover actions debug command [[#179](https://github.com/mrcjkb/rustaceanvim/issues/179)].
  Thanks [@Tired-Fox](https://github.com/Tired-Fox)!

## [3.17.1] - 2024-01-22

### Fixed

- Spawn rust-analyzer in detached mode when no project root is found.
  This adds support for standalone files without a Rust project.

## [3.17.0] - 2024-01-20

### Added

- Cache runnables and debuggables run with commands/code lenses.

## [3.16.3] - 2024-01-20

### Changed

- Performance (DAP): Use cached source map,
  LLDB commands and library path.
- DAP: Set `autoload_configurations` only for Neovim >= 0.10,
  as compiling the debug build is not async in Neovim 0.9.

## [3.16.2] - 2024-01-19

### Fixed

- DAP: `nil` error when executing `rust-analyzer.debugSingle`
  or `:RustLsp debuggables last` commands (introduced in 3.16.0).

## [3.16.1] - 2024-01-17

### Fixed

- DAP: Improve reliability of loading Rust debug configurations on LSP attach.
- DAP: Assign `lldb` and `codelldb` configurations found in `launch.json`
  to `dap.configurations.rust`.

## [3.16.0] - 2024-01-15

### Added

- DAP: Better `nvim-dap` integration:
  Automatically try to load Rust debug configurations on LSP attach.
  This lets you use `require('dap').continue()` instead of `:RustLsp debuggables`,
  once the configurations have been loaded.
  Can be disabled by setting `vim.g.rustaceanvim.dap.autoload_configurations = false`.

### Fixed

- LSP: If inlay hints are enabled for a buffer, force Neovim
  to redraw them when rust-analyzer has fully initialized.
  This is a workaround for [neovim/26511](https://github.com/neovim/neovim/issues/26511).
- LSP: On client stop, reset the `experimental/serverStatus` handler's
  internal state for the respective client, so that the handler can be
  rerun on restart.
- LSP/Windows: Normalize case sensitive `root_dir` [[#151](https://github.com/mrcjkb/rustaceanvim/issues/151)].
  Thanks [@TrungNguyen153](https://github.com/TrungNguyen153)!

## [3.15.0] - 2024-01-11

### Added

- `:RustAnalyzer restart` command.
- Smarter completions for `:RustAnalyzer` commands.
  - Only suggest `start` command if there is no
    active client for the current buffer
  - Only suggest `stop` and `restart` if there is an
    active client for the current buffer

## [3.14.0] - 2024-01-10

### Added

- `:RustLsp renderDiagnostic` command:
  Render diagnostics as displayed during `cargo build`.
- Add `Open in split` action to `explainError` and `renderDiagnostic`
  float preview windows.

## [3.13.1] - 2024-01-10

### Fixed

- DAP: Use `codelldb` adapter nvim-dap field when using `codelldb`.

## [3.13.0] - 2024-01-09

### Added

- Config: `tools.float_win_config` for all floating Windows
  created by this plugin.
  Moved `border`, `max_width`, `max_height`, `auto_focus`
  from `hover_actions` to `float_win_config`.
  The `hover_actions` window options are still applied
  if they exist, so as not to break compatibility.
  Thanks [@saying121](https://github.com/saying121)!

### Fixed

- DAP: Don't load `lldb_commands` when using `codelldb`.
- DAP: Make sure the client configuration type is 'codelldb'
  when using a 'codelldb' adapter.

## [3.12.2] - 2024-01-07

### Fixed

- LSP: Don't set `augmentsSyntaxTokens` capability.
  This appears to cause problems for some colorschemes.

## [3.12.1] - 2024-01-06

### Fixed

- Config: Report error if new validations fail.

## [3.12.0] - 2024-01-06

### Added

- Config: Some more validations.

## [3.11.0] - 2023-12-23

### Added

- LSP: `view [hir|mir]` command [[#14](https://github.com/mrcjkb/rustaceanvim/issues/14)],
  [[#15](https://github.com/mrcjkb/rustaceanvim/issues/15)].

### Fixed

- SSR: Make query optional.

## [3.10.5] - 2023-12-22

### Fixed

- Health: Only report error if `lspconfig.rust_analyzer` has been setup,
  not other lspconfig configurations.

## [3.10.4] - 2023-12-20

### Fixed

- SSR: Broken when command contains spaces [[#104](https://github.com/mrcjkb/rustaceanvim/issues/104)].
- LSP: Prevent "attempt to index a `nil` value" error [[#105](https://github.com/mrcjkb/rustaceanvim/issues/105)].

## [3.10.3] - 2023-12-19

### Fixed

- Health: Don't eagerly import modules.

## [3.10.2] - 2023-12-18

### Fixed

- DAP: Only add sourceMap and lldb commands if the files exist.
- DAP (Windows): Fixed .exe extension in mason.nvim codelldb detection.
  Thanks [@svermeulen](https://github.com/svermeulen)!

## [3.10.1] - 2023-12-14

### Fixed

- DAP: Check if mason dap package is installed [[#96](https://github.com/mrcjkb/rustaceanvim/issues/96)].
  Thanks [@richchurcher](https://github.com/richchurcher)!

## [3.10.0 - 2023-12-12

### Added

Thanks [@Andrew Collins](https://github.com/Andrew-Collins):

- DAP: Load the `dap.adapter` config value into the `lldb` adapter, but only if the
 `lldb` adapter is not already configured.
- DAP: Add `dap.configuration` entry to config with the default behaviour of loading
  `launch.json`, or falling back to a basic configuration of the `lldb` adapter.
  - Use the `dap.configuration` config value to configure the debug session,
    falling back to the `rust` configuration.
- DAP: Support [`probe-rs`](https://probe.rs/).

## [3.9.6] - 2023-12-06

### Fixed

- `nil` checks for when there is no root project.
  Fixes the error message encountered in [#90](https://github.com/mrcjkb/rustaceanvim/issues/90).

## [3.9.5] - 2023-12-05

### Fixed

- `:RustLsp flyCheck`: Typo in LSP client request,
  causing the command to do nothing [[#88](https://github.com/mrcjkb/rustaceanvim/issues/88)].

## [3.9.4] - 2023-12-01

### Fixed

- DAP: mason.nvim `codelldb` installation detection - liblldb path.

## [3.9.3] - 2023-12-01

### Fixed

- DAP: Typo in mason.nvim `codelldb` installation detection (╯°□°)╯︵ ┻━┻.

## [3.9.2] - 2023-12-01

### Fixed

- DAP: `loop error` when auto-detecting mason.nvim `codelldb` installation.
- DAP: Deprecate `require('rustaceanvim.dap').get_codelldb_adapter`
  (replaced with `require('rustaceanvim.config').get_codelldb_adapter`).

## [3.9.1] - 2023-12-01

### Fixed

- DAP: Potential bug when loading mason.nvim's `codelldb` package.
- DAP: Check that mason.nvim's `codelldb` package isn't `nil` before using it.

## [3.9.0] - 2023-12-01

### Added

- DAP: Auto-detect `codelldb` if it is installed via [mason.nvim](https://github.com/williamboman/mason.nvim).

## [3.8.0] - 2023-12-01

### Added

- `:RustLsp logFile` command, which opens the rust-analyzer log file.
- `:RustLsp flyCheck`: Support `run`, `clear` and `cancel` subcommands.
- Executors: Support commands without `cwd`.

### Fixed

- Health: Check if `vim.g.rustaceanvim` is set,
  but hasn't been sourced before initialization.

## [3.7.1] - 2023-11-28

### Fixed

- DAP: Correctly format environment, so that it works with both `codelldb`
  and `lldb` [[#74](https://github.com/mrcjkb/rustaceanvim/pull/74)].
  Thanks [@richchurcher](https://github.com/richchurcher)!

## [3.7.0] - 2023-11-27

### Added

- DAP: Support dynamically compiled executables [[#64]https://github.com/mrcjkb/rustaceanvim/pull/64).
  Thanks [@richchurcher](https://github.com/richchurcher)!
  - Configures dynamic library paths by default (with the ability to disable)
  - Loads Rust type information by default (with the ability to disable).

### Fixed

- DAP: Format `sourceMap` correctly for both `codelldb` and `lldb`.
  `codelldb` expects a map, while `lldb` expects a list of tuples.

## [3.6.5] - 2023-11-22

### Fixed

- Completion for `:RustLsp hover actions` command suggesting `action`.

## [3.6.4] - 2023-11-19

### Fixed

## [3.6.3] - 2023-11-18

- DAP: Source map should be a list of tuples, not a map.

### Fixed

- DAP: `lldb-vscode` and `lldb-dap` executable detection.

## [3.6.2] - 2023-11-17

### Fixed

- DAP: Add support for `lldb-dap`,
  which has been renamed to `lldb-vscode`, but may still have the
  old name on some distributions.

## [3.6.1] - 2023-11-17

### Fixed

- Broken `:RustLsp runnables last` command [[#62](https://github.com/mrcjkb/rustaceanvim/issues/62)].

## [3.6.0] - 2023-11-15

### Added

- Add `tools.open_url` option,
  to allow users to override how to open external docs.

## [3.5.1] - 2023-11-13

### Fixed

- Config validation fails if `server.settings` option is a table [[#56](https://github.com/mrcjkb/rustaceanvim/issues/56)].

## [3.5.0] - 2023-11-11

### Added

- Ability to load rust-analyzer settings from project-local JSON files.

## [3.4.2] - 2023-11-11

### Fixed

- Open external docs broken in Neovim 0.9 [[#50](https://github.com/mrcjkb/rustaceanvim/issues/50)].

## [3.4.1] - 2023-11-10

### Fixed

- Command completion broken in Neovim 0.9 [[#47](https://github.com/mrcjkb/rustaceanvim/issues/47)].

## [3.4.0] - 2023-11-01

### Added

- Auto-create `codelldb` configurations.

### Fixed

- DAP: Support `codelldb` configurations [[#40](https://github.com/mrcjkb/rustaceanvim/issues/40)].
- DAP: Don't pass in an empty source map table if the
  `auto_generate_source_map` setting evaluates to `false`.

## [3.3.3] - 2023-10-31

### Fixed

- Default rust-analyzer configuration [[#37](https://github.com/mrcjkb/rustaceanvim/issues/37)].
  Thanks again, [@eero-lehtinen](https://github.com/eero-lehtinen)!

## [3.3.2] - 2023-10-31

### Fixed

- Cargo workspace reload using removed command [[#36](https://github.com/mrcjkb/rustaceanvim/pull/36)].
  Thanks [@eero-lehtinen](https://github.com/eero-lehtinen)!

## [3.3.1] - 2023-10-31

### Fixed

- Neovim 0.9 compatibility layer: Missing `nil` checks [[#32](https://github.com/mrcjkb/rustaceanvim/issues/32)].

## [3.3.0] - 2023-10-30

### Added

- DAP: Auto-generate source map, to allow stepping into `std`.

## [3.2.1] - 2023-10-29

### Fixed

- `dap`/`quickfix` executor: Fix setting `cwd` for shell commands.

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

- Remove accidental use of Neovim nightly API
  (`dap`, `crateGraph`, `explainError`) [[#26](https://github.com/mrcjkb/rustaceanvim/issues/26)].
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

### BREAKING CHANGES

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

### BREAKING CHANGES compared to `rust-tools.nvim`

- [Removed the `setup` function](https://mrcjkb.dev/posts/2023-08-22-setup.html)
  and revamped the architecture to be less prone to type errors.
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
  for example ~~`:lua vim.cmd.RustSSR()` or `:RustSSR`~~ [This has changed! See above.].
- Bumped minimum Neovim version to `0.9`.
- Removed inlay hints, as this feature will be built into Neovim `0.10`.
