<!-- markdownlint-disable -->
# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.0.0](https://github.com/mrcjkb/rustaceanvim/compare/v5.14.0...v6.0.0) (2024-11-12)


### ⚠ BREAKING CHANGES

* **docs:** rename types in LuaCATS annotations and vimdoc.
* drop neovim 0.9 compatibility layer

### Features

* `:RustLsp logFile` command ([48801fe](https://github.com/mrcjkb/rustaceanvim/commit/48801fe4790a2962fbd6f87b4439c2ecd8c2151b))
* `:RustLsp openDocs` command ([#326](https://github.com/mrcjkb/rustaceanvim/issues/326)) ([c2cdbec](https://github.com/mrcjkb/rustaceanvim/commit/c2cdbeca8674e1b1b66ba870ff502bdad55a6d8a))
* `:RustLsp renderDiagnostic` command + open in split actions ([#146](https://github.com/mrcjkb/rustaceanvim/issues/146)) ([e4020e7](https://github.com/mrcjkb/rustaceanvim/commit/e4020e72a5562b9e7cd09e9cd025467f7b0ea76a))
* `run` and `debug` commands to run targets at current position ([#341](https://github.com/mrcjkb/rustaceanvim/issues/341)) ([a2af328](https://github.com/mrcjkb/rustaceanvim/commit/a2af328ad8fea6d680deaf6b96f1d075abf15376))
* `RustLsp explainError` command ([2168580](https://github.com/mrcjkb/rustaceanvim/commit/21685802b61b8c00db0c0dc46af2077d272be648))
* `RustLsp view [mir|hir]` command ([#110](https://github.com/mrcjkb/rustaceanvim/issues/110)) ([df6c116](https://github.com/mrcjkb/rustaceanvim/commit/df6c116b37b3523a3dfa23aa92da811084695c4b))
* `tools.cargo_override` option ([#340](https://github.com/mrcjkb/rustaceanvim/issues/340)) ([0db93dc](https://github.com/mrcjkb/rustaceanvim/commit/0db93dc36bf0f3395d2055c0d7239603fe9e3a1b))
* `viewHir` command ([#107](https://github.com/mrcjkb/rustaceanvim/issues/107)) ([b410f86](https://github.com/mrcjkb/rustaceanvim/commit/b410f86729c3d3b75c2f7be2dba24374444ac9a7))
* ability to load rust-analyzer settings from project-local json ([#54](https://github.com/mrcjkb/rustaceanvim/issues/54)) ([e3e0dc2](https://github.com/mrcjkb/rustaceanvim/commit/e3e0dc2ce1ba669ca8d8f367d76193829fe22192))
* add `tools.open_url` option to allow overriding url handler ([#58](https://github.com/mrcjkb/rustaceanvim/issues/58)) ([9c0b719](https://github.com/mrcjkb/rustaceanvim/commit/9c0b7199e3ad04478144211fd33fc40e485a043d))
* add hint on how to configure/disable server status notifications ([711e25f](https://github.com/mrcjkb/rustaceanvim/commit/711e25fe11b6e72fbeda52d9d81b85a5aa3a81ab))
* auto-detect the `rustc` edition ([d69d260](https://github.com/mrcjkb/rustaceanvim/commit/d69d2600e1079d40ab849a06fdc7eb0b2c595a6d))
* **commands:** `Rustc unpretty args[]` ([#194](https://github.com/mrcjkb/rustaceanvim/issues/194)) ([e348f69](https://github.com/mrcjkb/rustaceanvim/commit/e348f69b0efbf96be1a58daac5aa3dcc7942b340))
* completions for `:RustLsp` subcommands' arguments ([f745207](https://github.com/mrcjkb/rustaceanvim/commit/f7452078feeb9b3de8d3c73cd51aa54ac8748d8d))
* **config:** add some validations ([86a2682](https://github.com/mrcjkb/rustaceanvim/commit/86a26826b785ac8449f42425e0d4ffadb09f27ab))
* **config:** Allow overriding the root_dir ([#402](https://github.com/mrcjkb/rustaceanvim/issues/402)) ([691901d](https://github.com/mrcjkb/rustaceanvim/commit/691901d6e241382261c1a99da4e8180e5563d8af))
* **config:** apply float_win_config to floating windows ([#133](https://github.com/mrcjkb/rustaceanvim/issues/133)) ([07f2984](https://github.com/mrcjkb/rustaceanvim/commit/07f29846af8d91144b45d669c97b909865b1abf8))
* **config:** customisable group action icon ([#347](https://github.com/mrcjkb/rustaceanvim/issues/347)) ([555ba5e](https://github.com/mrcjkb/rustaceanvim/commit/555ba5e2f10626d16d07c58bc5953867505b899e))
* **config:** health check reports for .vscode/settings.json ([#539](https://github.com/mrcjkb/rustaceanvim/issues/539)) ([cb31013](https://github.com/mrcjkb/rustaceanvim/commit/cb31013a983faec6339d3bf6aad782da8fc7e111))
* **dap:** auto-detect `codelldb` if installed using mason.nvim ([#80](https://github.com/mrcjkb/rustaceanvim/issues/80)) ([67bbfc8](https://github.com/mrcjkb/rustaceanvim/commit/67bbfc8f60a8ebf09b7bed1986ce29dd1fe18bf1))
* **dap:** auto-generate source map to allow stepping into `std` ([#30](https://github.com/mrcjkb/rustaceanvim/issues/30)) ([f7415da](https://github.com/mrcjkb/rustaceanvim/commit/f7415da0baf9e7f2aacee4b0847a36cba67f97d5))
* **dap:** autoload nvim-dap configurations on LSP attach ([819ae2d](https://github.com/mrcjkb/rustaceanvim/commit/819ae2d889cca667e7410341c48955043be100a0))
* **dap:** evaluate adapter config when running debuggables ([d9640a6](https://github.com/mrcjkb/rustaceanvim/commit/d9640a610f986dbb2910c03e4a7b7d5c5e285279))
* **dap:** support `codelldb` ([#41](https://github.com/mrcjkb/rustaceanvim/issues/41)) ([af12503](https://github.com/mrcjkb/rustaceanvim/commit/af12503ec5f2937df53ffcfb1c95a57bce44c53c))
* **dap:** support dynamically compiled executable ([#64](https://github.com/mrcjkb/rustaceanvim/issues/64)) ([#72](https://github.com/mrcjkb/rustaceanvim/issues/72)) ([773110e](https://github.com/mrcjkb/rustaceanvim/commit/773110ef2ca87429789b6aa3854c593115d98dbd))
* **dap:** switch to using `lldb` adapter, dap-client configuration from config, load `launch.json` by default, `probe-rs` support ([#93](https://github.com/mrcjkb/rustaceanvim/issues/93)) ([adeca59](https://github.com/mrcjkb/rustaceanvim/commit/adeca597ba734ce8008cb8524d3281ab36a72528))
* **dap:** use integrated terminal for lldb-dap by default ([#494](https://github.com/mrcjkb/rustaceanvim/issues/494)) ([c3729ed](https://github.com/mrcjkb/rustaceanvim/commit/c3729edc4f4d502a089c770d7b8b877f4e2ee400))
* deprecate rust-analyzer.json ([7d917be](https://github.com/mrcjkb/rustaceanvim/commit/7d917beca9b6b84168197a6bac2d9067b895de42))
* **diagnostic:** ansi code colored disagnostics in floating and spli… ([#456](https://github.com/mrcjkb/rustaceanvim/issues/456)) ([102dd4c](https://github.com/mrcjkb/rustaceanvim/commit/102dd4c5e9f28c49820e67d2ba7e48954c2b89a3))
* **executors:** support commands without `cwd` ([86d1683](https://github.com/mrcjkb/rustaceanvim/commit/86d16837754d3e41ddcefe933642deddf3a25831))
* **flyCheck:** Support `run`, `clear` and `cancel` subcommands ([#78](https://github.com/mrcjkb/rustaceanvim/issues/78)) ([3e66b18](https://github.com/mrcjkb/rustaceanvim/commit/3e66b186d8749f180d12053632c5e026bf310a44))
* **health:** add check for neotest-rust conflict ([e2cdddb](https://github.com/mrcjkb/rustaceanvim/commit/e2cdddb0a2e274794717bfa9c951f8788543dac3))
* **health:** detect rust-analyzer wrapper without rust-analyzer ([#300](https://github.com/mrcjkb/rustaceanvim/issues/300)) ([3567d67](https://github.com/mrcjkb/rustaceanvim/commit/3567d6750fe577e7b4b756a017898e73c7634187))
* improvements to loading project-local settings ([#290](https://github.com/mrcjkb/rustaceanvim/issues/290)) ([bb06512](https://github.com/mrcjkb/rustaceanvim/commit/bb065126a8f19c6ccd075e9c0e4553ed613e9160))
* **init:** warn if nvim-lspconfig.rust_analyzer setup detected ([#316](https://github.com/mrcjkb/rustaceanvim/issues/316)) ([802fb1f](https://github.com/mrcjkb/rustaceanvim/commit/802fb1f2388514b61466127c23dd41c34e86f28c))
* **lsp/codeAction:** add `&lt;ESC&gt;` keymap to close buffer ([b44e1db](https://github.com/mrcjkb/rustaceanvim/commit/b44e1db9056d74cc491aa4a3f625f8bdca0d6743))
* **lsp:** `:RustAnalyzer restart` command ([8b3c225](https://github.com/mrcjkb/rustaceanvim/commit/8b3c2254f72b9e614436cc94ecdc20157760774e))
* **lsp:** `&lt;Plug&gt;` mapping for hover actions ([#510](https://github.com/mrcjkb/rustaceanvim/issues/510)) ([b52bbc4](https://github.com/mrcjkb/rustaceanvim/commit/b52bbc4bb0e50bf7da65b2695e1d602344877858))
* **lsp:** `RustLsp testables` command + failed test diagnostics ([#197](https://github.com/mrcjkb/rustaceanvim/issues/197)) ([7c63115](https://github.com/mrcjkb/rustaceanvim/commit/7c63115b539e56b29194f733c7ae804b99c0e4e5))
* **lsp:** add command to reload lsp settings ([#309](https://github.com/mrcjkb/rustaceanvim/issues/309)) ([04dc55d](https://github.com/mrcjkb/rustaceanvim/commit/04dc55d70f955dc28c4b44ad130bf1f513909e59))
* **lsp:** allow overriding server command via `rust-analzyer.server.path` setting ([#567](https://github.com/mrcjkb/rustaceanvim/issues/567)) ([7a8665b](https://github.com/mrcjkb/rustaceanvim/commit/7a8665bdf891ec00277704fd4a5b719587ca9082))
* **lsp:** arguments to explainError/renderDiagnostic from current line ([#431](https://github.com/mrcjkb/rustaceanvim/issues/431)) ([34fb2b4](https://github.com/mrcjkb/rustaceanvim/commit/34fb2b400e33f7ec3ef05360dcb2a79180277589))
* **lsp:** auto-detect some extra plugin client capabilities ([d104ab2](https://github.com/mrcjkb/rustaceanvim/commit/d104ab22d55499240ea03856a214deca4668f8e1))
* **lsp:** cache runnables and debuggables run with commands/code lenses ([b0c03f0](https://github.com/mrcjkb/rustaceanvim/commit/b0c03f052d24a2bfc4cc681075c2d81d3c3ac2f7))
* **lsp:** don't auto-attach to buffers that aren't files ([#272](https://github.com/mrcjkb/rustaceanvim/issues/272)) ([44465ee](https://github.com/mrcjkb/rustaceanvim/commit/44465eec3c1b9f7c6620274218fd8e9e60d6618e))
* **lsp:** enable clippy lints if cargo-clippy is detected ([98b905d](https://github.com/mrcjkb/rustaceanvim/commit/98b905d37d2751a4391ad096cf741930406d0ce0))
* **lsp:** enable server-side file watching if client-side disabled ([#427](https://github.com/mrcjkb/rustaceanvim/issues/427)) ([17f72a2](https://github.com/mrcjkb/rustaceanvim/commit/17f72a28c887512eabeaf616b604ff5c763ee8db))
* **lsp:** filtered workspace symbol searches ([#205](https://github.com/mrcjkb/rustaceanvim/issues/205)) ([4612dd6](https://github.com/mrcjkb/rustaceanvim/commit/4612dd6e43bfc0d0f3728023b1a486e0924770f0))
* **lsp:** improved parsing of test result error messages ([8df46c8](https://github.com/mrcjkb/rustaceanvim/commit/8df46c8bb458dfc176718cc956493b1ca09252f1))
* **lsp:** join multiple visually selected lines (`RustLsp joinLines`) ([#339](https://github.com/mrcjkb/rustaceanvim/issues/339)) ([e9db3d5](https://github.com/mrcjkb/rustaceanvim/commit/e9db3d53142f8c707eb4a62d01007ce6b02cef56))
* **lsp:** load `.vscode/settings.json` settings by default ([cb83e41](https://github.com/mrcjkb/rustaceanvim/commit/cb83e412f0552df3957a5d3e5f29c1ea4b777975))
* **lsp:** more information on LSP errors ([#509](https://github.com/mrcjkb/rustaceanvim/issues/509)) ([4786724](https://github.com/mrcjkb/rustaceanvim/commit/4786724810d040c5b7607291323ac23da0d8a2ae))
* **lsp:** notify if rust-analyzer status is not healthy ([#508](https://github.com/mrcjkb/rustaceanvim/issues/508)) ([5c0c441](https://github.com/mrcjkb/rustaceanvim/commit/5c0c44149e43b907dae2e0fe053284ad56226eb7))
* **lsp:** only notify on server status error by default ([#519](https://github.com/mrcjkb/rustaceanvim/issues/519)) ([360ac5c](https://github.com/mrcjkb/rustaceanvim/commit/360ac5c80f299f282cbb1967bbfe5aa1e1c6e66e))
* **lsp:** option to fall back to `vim.ui.select` for code action ([#185](https://github.com/mrcjkb/rustaceanvim/issues/185)) ([d1e1492](https://github.com/mrcjkb/rustaceanvim/commit/d1e1492ef7fb06fd998a436013ce924b3210dc40))
* **lsp:** pass default settings to server.settings function ([#291](https://github.com/mrcjkb/rustaceanvim/issues/291)) ([69a22c2](https://github.com/mrcjkb/rustaceanvim/commit/69a22c2ec63ab375190006751562b62ebb318250))
* **lsp:** preserve cursor position for move_item command ([#532](https://github.com/mrcjkb/rustaceanvim/issues/532)) ([a07bb0d](https://github.com/mrcjkb/rustaceanvim/commit/a07bb0d256d1f9693ae8fb96dbcc5350b18f2978))
* **lsp:** smart completions for `:RustAnalyzer` subcommands ([5ee9a98](https://github.com/mrcjkb/rustaceanvim/commit/5ee9a9867f7593d1696fb95a714cf78563052e90))
* **lsp:** support falling back to ui select for `testables/runnables` ([#277](https://github.com/mrcjkb/rustaceanvim/issues/277)) ([19f1217](https://github.com/mrcjkb/rustaceanvim/commit/19f12173ccb7993f86ea26b0e21bbb883c3b86c7))
* **lsp:** target architecture switching command for `RustAnalyzer` ([#541](https://github.com/mrcjkb/rustaceanvim/issues/541)) ([95715b2](https://github.com/mrcjkb/rustaceanvim/commit/95715b28c87b4cb3a8a38e063e2aa5cd3a8024d7))
* neotest adapter ([3015cf3](https://github.com/mrcjkb/rustaceanvim/commit/3015cf38f7ef9ebe485c14c318a123ccfdcf8bd3))
* **neotest:** basic support for `suite = true` ([#204](https://github.com/mrcjkb/rustaceanvim/issues/204)) ([3dabf63](https://github.com/mrcjkb/rustaceanvim/commit/3dabf63f1c6674cd6be5888bcd680c7c20b76d7d))
* **neotest:** expose doctests on Neotest summary window ([#247](https://github.com/mrcjkb/rustaceanvim/issues/247)) ([50b60ca](https://github.com/mrcjkb/rustaceanvim/commit/50b60ca4be7548e8bef8522d5cfb6be5b895ef67))
* **neotest:** support dap strategy ([38558fa](https://github.com/mrcjkb/rustaceanvim/commit/38558fa486380fd014ea271dad50a17573c76c31))
* **nix:** provide `codelldb` flake output ([8c2f313](https://github.com/mrcjkb/rustaceanvim/commit/8c2f313fa800fc12112bc600a156395c2f044306))
* remove remaining `plenary.nvim` dependencies ([568ee1b](https://github.com/mrcjkb/rustaceanvim/commit/568ee1bcabaed79c19a8c5b3cb512b4a2e9d0d04))
* **rustc:** do not require a main function + support 2024 edition ([#225](https://github.com/mrcjkb/rustaceanvim/issues/225)) ([19e7a9a](https://github.com/mrcjkb/rustaceanvim/commit/19e7a9a4ac93edc8b3bb4b5e129a1d1bc724555f))
* **ssr:** support visual selection range ([#160](https://github.com/mrcjkb/rustaceanvim/issues/160)) ([e2dbf91](https://github.com/mrcjkb/rustaceanvim/commit/e2dbf91daed26d4dd7263affbecbf9a36e0096e5))
* **testables,neotest:** cargo-nextest support ([144c40d](https://github.com/mrcjkb/rustaceanvim/commit/144c40dfd1b1684d1f4f4b14e4e6701686b63889))
* **testables:** add `crate_test_executor` option for `--all-targets` ([1ffc8c3](https://github.com/mrcjkb/rustaceanvim/commit/1ffc8c3fe23856b45540583c8537082032b8053f))
* **testables:** prettier selection options ([28d8c92](https://github.com/mrcjkb/rustaceanvim/commit/28d8c9234201398d5131ed3f22c22e6f3ccdf64d))
* **ui:** add `open_split_vertical` option for splits opened ([#387](https://github.com/mrcjkb/rustaceanvim/issues/387)) ([3c822ac](https://github.com/mrcjkb/rustaceanvim/commit/3c822ac7807f3c9753e5c46be3223da578bf33b8))
* **vimdoc:** tags ([30a8c04](https://github.com/mrcjkb/rustaceanvim/commit/30a8c04ecf96c9818fe9cb99396edfe92476182c))


### Bug Fixes

* **checkhealth:** lldb check hangs if lldb-vscode is installed ([5ae04f9](https://github.com/mrcjkb/rustaceanvim/commit/5ae04f957277f10d8b183a2d5902f82c91cb5be2))
* command completion broken in neovim 0.9 ([#48](https://github.com/mrcjkb/rustaceanvim/issues/48)) ([64edff2](https://github.com/mrcjkb/rustaceanvim/commit/64edff2b2ab8281afcc55f140303e357a35a649f))
* **commands:** completion for hover actions suggesting "action" ([28b7390](https://github.com/mrcjkb/rustaceanvim/commit/28b7390187e9eebaa4cc97fcc08c613ea951fa57))
* **compat:** add missing nil checks ([#33](https://github.com/mrcjkb/rustaceanvim/issues/33)) ([e3a543b](https://github.com/mrcjkb/rustaceanvim/commit/e3a543b76a298295b681742f292f803b517f1d5d))
* compatibility with neovim-stable + type checker for neovim-stable ([#27](https://github.com/mrcjkb/rustaceanvim/issues/27)) ([a0e8b51](https://github.com/mrcjkb/rustaceanvim/commit/a0e8b510b04043865dffe940f50b53a66411e578))
* compatibility with nvim-nightly ([0b40190](https://github.com/mrcjkb/rustaceanvim/commit/0b401909394d15898e4a8fcf959f74cbcba5d3ca))
* config validation fails if `server.settings` option is a table ([#57](https://github.com/mrcjkb/rustaceanvim/issues/57)) ([a3798bd](https://github.com/mrcjkb/rustaceanvim/commit/a3798bd1ff739a948cdff88d14b7b14067b01292))
* **config:** don't validate types defined in external APIs ([#298](https://github.com/mrcjkb/rustaceanvim/issues/298)) ([2b0377e](https://github.com/mrcjkb/rustaceanvim/commit/2b0377e446694580f296fb4b3243fcc11e00f73e))
* **config:** report error if new validations fail ([f36e3a6](https://github.com/mrcjkb/rustaceanvim/commit/f36e3a62b81b9a4ebd1771e6ee81fb5d85383af8))
* **dap/`codelldb`:** redirect `stdio` to a temp file ([ada6e6b](https://github.com/mrcjkb/rustaceanvim/commit/ada6e6b1f40fc22c4824351f55e1349de99abe24))
* **dap/quickfix:** set `cwd` in shell command ([5f94fd7](https://github.com/mrcjkb/rustaceanvim/commit/5f94fd7697d1cf1b8704827a351dc7ef61d35c18))
* **dap:** `lldb-vscode` and `lldb-dap` executable detection ([468cff5](https://github.com/mrcjkb/rustaceanvim/commit/468cff5126fb709ad990404eab1593e79eecc9d0))
* **dap:** `loop` error when auto-detecting mason.nvim codelldb package ([#84](https://github.com/mrcjkb/rustaceanvim/issues/84)) ([72553d6](https://github.com/mrcjkb/rustaceanvim/commit/72553d6802815c04729344153d35d6fd90dd891d))
* **dap:** `nil` error on `rust-analyzer debugSingle`/`debuggables last` ([dcd8c9a](https://github.com/mrcjkb/rustaceanvim/commit/dcd8c9a316ab74012f5da87bf56ad51b3c060c30))
* **dap:** `nil` saftety in standalone files. ([#183](https://github.com/mrcjkb/rustaceanvim/issues/183)) ([bc8c4b8](https://github.com/mrcjkb/rustaceanvim/commit/bc8c4b8f7606d5b7c067cd8369e25c1a7ff77bd0))
* **dap:** account for removed `cargoExtraArgs` ([#450](https://github.com/mrcjkb/rustaceanvim/issues/450)) ([047f9c9](https://github.com/mrcjkb/rustaceanvim/commit/047f9c9d8cd2861745eb9de6c1570ee0875aa795))
* **dap:** autoload new configurations in `on_attach` ([7875217](https://github.com/mrcjkb/rustaceanvim/commit/78752170430c046ef2fd0c96b2f93ec130643093))
* **dap:** bad config validation ([b0d5e49](https://github.com/mrcjkb/rustaceanvim/commit/b0d5e4929e8c839baa4ab4adb152f20db5467c33))
* **dap:** don't error if getting source/library info fails ([989e411](https://github.com/mrcjkb/rustaceanvim/commit/989e411017f36bd35d7c16cf3008af75e27d03fe))
* **dap:** don't load `lldb_commands` when using `codelldb` ([#140](https://github.com/mrcjkb/rustaceanvim/issues/140)) ([eaa3296](https://github.com/mrcjkb/rustaceanvim/commit/eaa3296560713657abf8b2d9cc082f5dd8d46b73))
* **dap:** dynamic library path setup fix ([#425](https://github.com/mrcjkb/rustaceanvim/issues/425)) ([368b614](https://github.com/mrcjkb/rustaceanvim/commit/368b614467ba99b38032d20e5b7ebbbbe822729a))
* **dap:** ensure `codelldb` client type when using `codelldb` adapter ([#141](https://github.com/mrcjkb/rustaceanvim/issues/141)) ([61ca8b7](https://github.com/mrcjkb/rustaceanvim/commit/61ca8b71d026b2c0e0511ed6a2e8ba099fa2efe3))
* **dap:** format `sourceMap` correctly for both `codelldb` and `lldb` ([a0eaffc](https://github.com/mrcjkb/rustaceanvim/commit/a0eaffcca5e91a68bcc8a6afe99ca33b54d06398))
* **dap:** has_package -&gt; is_installed ([#97](https://github.com/mrcjkb/rustaceanvim/issues/97)) ([b76ae2a](https://github.com/mrcjkb/rustaceanvim/commit/b76ae2ae71c37c21124429c8a134023edbb6b559))
* **dap:** improve reliability of automatic nvim-dap registration ([597c8d6](https://github.com/mrcjkb/rustaceanvim/commit/597c8d6c7b4433ec4577b73bced1df41c132b077))
* **dap:** improve reliability of debuggable auto loading ([#167](https://github.com/mrcjkb/rustaceanvim/issues/167)) ([ea10533](https://github.com/mrcjkb/rustaceanvim/commit/ea105333daea50823d30842adeae1a763d1e88f6))
* **dap:** lldb library paths are strings ([#74](https://github.com/mrcjkb/rustaceanvim/issues/74)) ([10c3c10](https://github.com/mrcjkb/rustaceanvim/commit/10c3c1063f80718e306d9b32a0c7db24a028c137))
* **dap:** make sourceMap a list of tuples, not a map ([#68](https://github.com/mrcjkb/rustaceanvim/issues/68)) ([540ff82](https://github.com/mrcjkb/rustaceanvim/commit/540ff82e5f47f3e39bd583acfbd813f4ac90d4a6))
* **dap:** mason debugger detection - liblldb path ([3cad691](https://github.com/mrcjkb/rustaceanvim/commit/3cad6912b16d5e0a5375d465ca28fda4c6ea4ee9))
* **dap:** only add sourceMap and lldb commands if the files exist ([#102](https://github.com/mrcjkb/rustaceanvim/issues/102)) ([a13e311](https://github.com/mrcjkb/rustaceanvim/commit/a13e311d449034b49d0144a411e0c8be3d5354cd))
* **dap:** only load .vscode/launch.json configs that don't conflict ([d6fd0b7](https://github.com/mrcjkb/rustaceanvim/commit/d6fd0b78e49ff4dd37070155e9f14fd26f2ef53f))
* **dap:** potential bug when loading mason.nvim's `codelldb` package ([#82](https://github.com/mrcjkb/rustaceanvim/issues/82)) ([6ca471b](https://github.com/mrcjkb/rustaceanvim/commit/6ca471bfe5988e9637e8e7c484c19991c5918133))
* **dap:** prevent parallel cargo test builds ([#501](https://github.com/mrcjkb/rustaceanvim/issues/501)) ([5610d5e](https://github.com/mrcjkb/rustaceanvim/commit/5610d5e01dc803717cc0b6b87625f2fbb548b49e))
* **dap:** show stdout and stderr if debug build compilation fails ([f92319c](https://github.com/mrcjkb/rustaceanvim/commit/f92319cfa1ad4c260da84e163767d52c6a771d31))
* **dap:** support `lldb-dap` ([7f8feb0](https://github.com/mrcjkb/rustaceanvim/commit/7f8feb045482113bfbe849843c9e1800ea350f07))
* **dap:** typo in mason.nvim codelldb detection ([a57bcf3](https://github.com/mrcjkb/rustaceanvim/commit/a57bcf3b56b8d580a840e81ba7e05ce6784e0565))
* **dap:** use `codelldb` nvim-dap field when using `codelldb` ([#144](https://github.com/mrcjkb/rustaceanvim/issues/144)) ([207f284](https://github.com/mrcjkb/rustaceanvim/commit/207f2845f3cfb15840c8a94b2fb3077068ab25ac))
* **dap:** use deep copies of dap configs ([1e0267e](https://github.com/mrcjkb/rustaceanvim/commit/1e0267e0a58038fb03b3e90def7a773bf60a24b6))
* **default-config:** rust-analyzer settings ([#39](https://github.com/mrcjkb/rustaceanvim/issues/39)) ([0664cb4](https://github.com/mrcjkb/rustaceanvim/commit/0664cb4fab21cb3eaf0585d78181e28a429441ad))
* **diagnostic:** pass correct flycheck arg for clear/cancel ([#477](https://github.com/mrcjkb/rustaceanvim/issues/477)) ([7f6d3d7](https://github.com/mrcjkb/rustaceanvim/commit/7f6d3d79ea680b8ca9af83b5cb3339ead711049b))
* don't set deprecated `allFeatures` setting by default ([#424](https://github.com/mrcjkb/rustaceanvim/issues/424)) ([66b888c](https://github.com/mrcjkb/rustaceanvim/commit/66b888cbbf9dd4e2cc5f70677c8bf82368dd68c9))
* **enable_clippy:** use correct rust-analyzer config key ([#403](https://github.com/mrcjkb/rustaceanvim/issues/403)) ([3b5e51c](https://github.com/mrcjkb/rustaceanvim/commit/3b5e51cba2c0cb94677033060d6ecd9f857ed166))
* error when decoding invalid JSON from cargo metadata. ([d69653a](https://github.com/mrcjkb/rustaceanvim/commit/d69653afc99e9c0cb6be0d1f26499a787f00a78d))
* **flyCheck:** correct typo in LSP client request ([#89](https://github.com/mrcjkb/rustaceanvim/issues/89)) ([d747f19](https://github.com/mrcjkb/rustaceanvim/commit/d747f194a2cae74da47fa665a86edb0a48b8139b))
* **ftplugin:** Properly sanitize hover actions debug command ([#180](https://github.com/mrcjkb/rustaceanvim/issues/180)) ([cce06ba](https://github.com/mrcjkb/rustaceanvim/commit/cce06ba73a41e0a7ba3ee719f284e0d458ee8dce))
* **health:** check if `vim.g.rustaceanvim` was set but not sourced ([f8f0341](https://github.com/mrcjkb/rustaceanvim/commit/f8f03415a28b50fe347fb3a2d2c1b803d61f37ea))
* **health:** don't eagarly load modules ([9afd89a](https://github.com/mrcjkb/rustaceanvim/commit/9afd89a036a2c9363ea631a5a7ad96c66c9eebc3))
* **health:** only error if `lspconfig.rust_analyzer` has been setup ([259f881](https://github.com/mrcjkb/rustaceanvim/commit/259f881c6bea51338e5ff72fc3a366008013c8c6))
* **health:** prevent false-positive rust-analyzer detections ([701fd23](https://github.com/mrcjkb/rustaceanvim/commit/701fd234b5f80b56ff827b6394d8773d931cc324))
* **health:** rust-analyzer reported as not found in neovim 0.9 ([b0548ff](https://github.com/mrcjkb/rustaceanvim/commit/b0548ff58d34caa220f8806c518fedb6453fc48e))
* **health:** tree-sitter-rust parser check on Windows ([5c721b3](https://github.com/mrcjkb/rustaceanvim/commit/5c721b3e55e34dd74526fb38f2f243bd2ca3a80b))
* **health:** warn if no debug adapters have been detected ([cf0ba61](https://github.com/mrcjkb/rustaceanvim/commit/cf0ba61cbcc5dcfafee080e1426ec655d1ff16ed))
* **internal:** don't pass client not found error to handler ([4ffd55f](https://github.com/mrcjkb/rustaceanvim/commit/4ffd55fe64f7c8dc3c1c7aad252aa0467cbc6480))
* **lsp,neotest:** normalize file before root_dir comparison  ([#245](https://github.com/mrcjkb/rustaceanvim/issues/245)) ([e536434](https://github.com/mrcjkb/rustaceanvim/commit/e536434de99e43caf89fec83ed1b7aff21e5b057))
* **lsp/dap:** fail silently if adding dap config on attach fails ([fb9ef10](https://github.com/mrcjkb/rustaceanvim/commit/fb9ef10d2b0b343b8767c57570ccf80071346ad9))
* **lsp/standalone:** use correct bufnr for detached file name ([29cc0dc](https://github.com/mrcjkb/rustaceanvim/commit/29cc0dc24f4409fad079e2dd669ecfc347e923f6))
* **lsp/windows:** path normalisation preventing lsp client from working ([387ca84](https://github.com/mrcjkb/rustaceanvim/commit/387ca846d632f8c90631536341ca1778b4c2c497))
* **lsp/windows:** path normalisation preventing lsp to work after gd to std lib ([#285](https://github.com/mrcjkb/rustaceanvim/issues/285)) ([a59b4e0](https://github.com/mrcjkb/rustaceanvim/commit/a59b4e04f7ac55a805b9705ac0a0653c5adca459))
* **lsp:** `checkOnSave = false` not respected if clippy is installed ([#230](https://github.com/mrcjkb/rustaceanvim/issues/230)) ([ae759e6](https://github.com/mrcjkb/rustaceanvim/commit/ae759e6c1de448b5aef0d1b3da534e21d7bee3e8))
* **lsp:** `nil` check for when no root directory is found ([#91](https://github.com/mrcjkb/rustaceanvim/issues/91)) ([d7cb051](https://github.com/mrcjkb/rustaceanvim/commit/d7cb051d2fc27e35c924b367f16123b8e261c769))
* **lsp:** `nil` error on `RustLsp! testables` if no previous testable ([e99d5b9](https://github.com/mrcjkb/rustaceanvim/commit/e99d5b9fd81d2f0e8cfcf916bbd544eb1a92618d))
* **lsp:** allow to run some RustLsp commands from non-rust buffers ([146d966](https://github.com/mrcjkb/rustaceanvim/commit/146d9662f19abcf2690a73b3543e232861799884))
* **lsp:** clear Cargo.toml buffer autocommands before creating them ([1f2e522](https://github.com/mrcjkb/rustaceanvim/commit/1f2e522bb67f335a221527e7772f198e183f7ce9))
* **lsp:** copy settings to init_options when starting the server to match VSCode ([#490](https://github.com/mrcjkb/rustaceanvim/issues/490)) ([1e4d10d](https://github.com/mrcjkb/rustaceanvim/commit/1e4d10d1435725d4dc8bc46f7aec0ec402ce7d67))
* **lsp:** don't set `augmentSyntaxTokens` client capability ([73854d5](https://github.com/mrcjkb/rustaceanvim/commit/73854d5e720d4ea135e7508d9d24fb82b4ec8223))
* **lsp:** don't try to delete user command if it doesn't exist ([6081be4](https://github.com/mrcjkb/rustaceanvim/commit/6081be4d9f7cef2382326450cfff2be0cace6688))
* **lsp:** error when opening a rust file that does not exist ([#405](https://github.com/mrcjkb/rustaceanvim/issues/405)) ([a73e861](https://github.com/mrcjkb/rustaceanvim/commit/a73e8618d8518b2a7434e1c21e4da4e66f21f738))
* **lsp:** escape character inserted before `}` on code action ([#338](https://github.com/mrcjkb/rustaceanvim/issues/338)) ([d107d75](https://github.com/mrcjkb/rustaceanvim/commit/d107d75dec3292137f8ff19d09906306b910e943))
* **lsp:** fail silently when trying to delete user command ([67c0970](https://github.com/mrcjkb/rustaceanvim/commit/67c09704d1a2ceab8be26b203e913d1f8bfe127c))
* **lsp:** fix resetting client state on stop if one client attached ([ce119c0](https://github.com/mrcjkb/rustaceanvim/commit/ce119c0ec359993f000be95f335dacf62a35882d))
* **lsp:** focus lost after `:RustLsp codeAction` second float opens ([#184](https://github.com/mrcjkb/rustaceanvim/issues/184)) ([87fc16d](https://github.com/mrcjkb/rustaceanvim/commit/87fc16de1360cda02470824a17e0073967bf29f1))
* **lsp:** force-extend capabilities with detected plugin capabilities ([2fa4542](https://github.com/mrcjkb/rustaceanvim/commit/2fa45427c01ded4d3ecca72e357f8a60fd8e46d4))
* **lsp:** inability to load rust-analyzer.json without rust-analzyer key ([e306c74](https://github.com/mrcjkb/rustaceanvim/commit/e306c742bd7f7183e371cd91268b72d9db1bbae0))
* **lsp:** load rust-analyzer.json into correct config field ([1e9ae23](https://github.com/mrcjkb/rustaceanvim/commit/1e9ae2309294084caa3c91b84b4c03bfea76ee29))
* **lsp:** normalize case sensitive `root_dir` on Windows ([#152](https://github.com/mrcjkb/rustaceanvim/issues/152)) ([c549be2](https://github.com/mrcjkb/rustaceanvim/commit/c549be2af16e9c5c10f09d7d47b10a1e219d6563))
* **lsp:** notify if no rust-analyzer client found for LSP request ([4d7cc0c](https://github.com/mrcjkb/rustaceanvim/commit/4d7cc0cbc0e7bd86ec8fa4214eb67bbf4c81e51d))
* **lsp:** only advertise `debugSingle` capability if nvim-dap is found ([259dbb7](https://github.com/mrcjkb/rustaceanvim/commit/259dbb7517000cc875a7a0f29426738cc762f342))
* **lsp:** only setup `vim.lsp.commands` for rust-analyzer on first init ([a24df27](https://github.com/mrcjkb/rustaceanvim/commit/a24df27ef0ab412227ae0d7b40276f0711966834))
* **lsp:** prevent 'attempt to index a `nil` value' error ([f158a58](https://github.com/mrcjkb/rustaceanvim/commit/f158a58df59d9631c4e66e0a602f93f630a7f64b))
* **lsp:** prevent hash collisions when searching diagnostics ([d23310b](https://github.com/mrcjkb/rustaceanvim/commit/d23310b519f8eeba539805bd6b9098b51b006979))
* **lsp:** register `snippetSupport` capability only if using nvim &gt;= 0.10 ([66466d4](https://github.com/mrcjkb/rustaceanvim/commit/66466d4fe0b8988ba9e2932d3c41782c2efb683b))
* **lsp:** reload cargo workspace broken when opening another buffer ([#271](https://github.com/mrcjkb/rustaceanvim/issues/271)) ([e9ae15b](https://github.com/mrcjkb/rustaceanvim/commit/e9ae15b890b4023cf96cf49acfeb96fcc1150d16))
* **lsp:** renderDiagnostic and explainError hash collisions ([c81f036](https://github.com/mrcjkb/rustaceanvim/commit/c81f0368dabef8a630f32373f1856c086ab8ee0f))
* **lsp:** renderDiagnostic and explainError stop searching early ([7b78743](https://github.com/mrcjkb/rustaceanvim/commit/7b78743202f78bd4155126ecde7b4c1229fe81b9))
* **lsp:** renderDiagnostic not moving cursor on fallback ([a8ee8f4](https://github.com/mrcjkb/rustaceanvim/commit/a8ee8f4a20da43a6ffeeb294ddf2b4dd81ab800a))
* **lsp:** renderDiagnostics and explainError skip valid diagnostics ([db303a4](https://github.com/mrcjkb/rustaceanvim/commit/db303a486f48376de3e49d34ee7cf444e197d1e1))
* **lsp:** reuse client when viewing git dependencies ([#374](https://github.com/mrcjkb/rustaceanvim/issues/374)) ([987f230](https://github.com/mrcjkb/rustaceanvim/commit/987f230a872dc0f67052f11ad3bfdbc248455858))
* **lsp:** schedule api calls in `on_exit` ([#267](https://github.com/mrcjkb/rustaceanvim/issues/267)) ([001dd49](https://github.com/mrcjkb/rustaceanvim/commit/001dd498894e4c554e92af507fb27739146c177d))
* **lsp:** spawn rust-analyzer in detached mode if no project root found ([#178](https://github.com/mrcjkb/rustaceanvim/issues/178)) ([a095a1f](https://github.com/mrcjkb/rustaceanvim/commit/a095a1f9397310d108ead239edc068b2624695b6))
* **lsp:** support completions for `RustLsp` with selection ranges ([a1d32cd](https://github.com/mrcjkb/rustaceanvim/commit/a1d32cd1d460046ae2d7b5657fe15585057bd028))
* **lsp:** support top level object + rust-analyzer key in rust-analyzer.json ([#243](https://github.com/mrcjkb/rustaceanvim/issues/243)) ([6865782](https://github.com/mrcjkb/rustaceanvim/commit/6865782798bdca0d8f1b3a598fef878b001422d8))
* **lsp:** update deprecated API calls ([#514](https://github.com/mrcjkb/rustaceanvim/issues/514)) ([9a36905](https://github.com/mrcjkb/rustaceanvim/commit/9a369055aebd0411a11600f7cfd5c9b39c751eaa))
* **lsp:** update testables cache if `runSingle` is a test ([2126b81](https://github.com/mrcjkb/rustaceanvim/commit/2126b818ca02ccd4b10ece44a43c381a31239579))
* **lsp:** use file directory name as cwd when getting cargo metadata ([5781eef](https://github.com/mrcjkb/rustaceanvim/commit/5781eef090d9b0c3f0fba5ecad7987ecfd20c880))
* **lsp:** workaround for inlay hint rendering + fix serverStatus handler ([#156](https://github.com/mrcjkb/rustaceanvim/issues/156)) ([a22fa8e](https://github.com/mrcjkb/rustaceanvim/commit/a22fa8e0d3a2f4ced6d0949b7484619706f65344))
* **neotest:** correctly mark passed and skipped tests in file/module runs ([#322](https://github.com/mrcjkb/rustaceanvim/issues/322)) ([76da238](https://github.com/mrcjkb/rustaceanvim/commit/76da238ba8eee5993756fb941eaa157081b96be9))
* **neotest:** multiple `--no-run` flags added to debug command ([#358](https://github.com/mrcjkb/rustaceanvim/issues/358)) ([553a319](https://github.com/mrcjkb/rustaceanvim/commit/553a3199c71be13328e1844e05a33faae1b5ae14))
* **neotest:** nested modules + position updates when switching buffers ([#223](https://github.com/mrcjkb/rustaceanvim/issues/223)) ([f8a33fb](https://github.com/mrcjkb/rustaceanvim/commit/f8a33fb8bee20b27ecd15694ceaedd96a5205471))
* **neotest:** no tests found when getting root dir for directory ([1cc5e06](https://github.com/mrcjkb/rustaceanvim/commit/1cc5e0605487b8d56d5766a82793a39ee2b11976))
* **neotest:** positions only queried for current buffer ([4af9aac](https://github.com/mrcjkb/rustaceanvim/commit/4af9aacd46572e25fca3e6f08706aabc5268a375))
* **neotest:** remove unsupported `--show-output` flag for cargo-nextest ([#384](https://github.com/mrcjkb/rustaceanvim/issues/384)) ([2eb8776](https://github.com/mrcjkb/rustaceanvim/commit/2eb8776df1aab03f514b38ddc39af57efbd8970b))
* **neotest:** replace nightly API call ([3d3818a](https://github.com/mrcjkb/rustaceanvim/commit/3d3818a6e4f88e1ccf40088df0cc3f525e0cbdf8))
* **neotest:** support nextest 0.9.7 ([95fb3e8](https://github.com/mrcjkb/rustaceanvim/commit/95fb3e8b8ebfe1f2eb5f172b422c7d8d321f9ad8))
* **neotest:** undo sanitize command for debugging in normal strategy ([78cbea3](https://github.com/mrcjkb/rustaceanvim/commit/78cbea31f81595dc68bdefd21127b9b4792722de))
* **neotest:** use all LSP clients to search for test positions ([#209](https://github.com/mrcjkb/rustaceanvim/issues/209)) ([8940ef5](https://github.com/mrcjkb/rustaceanvim/commit/8940ef5c7e3ffd37712ac0556832b5b10a136874))
* open external docs broken in neovim 0.9 ([#52](https://github.com/mrcjkb/rustaceanvim/issues/52)) ([bbcee20](https://github.com/mrcjkb/rustaceanvim/commit/bbcee2077903bb1160d24ffdbe077f227ad90bdf))
* **quickfix:** Always add both `stdout` and `stderr` to qf list ([44b74ba](https://github.com/mrcjkb/rustaceanvim/commit/44b74badad1b0a14c492fe8958f63586dd3acd06))
* **quickfix:** populated with a single line ([7da155a](https://github.com/mrcjkb/rustaceanvim/commit/7da155a907e3f48b1f7c25c59e248996fba833df))
* remove corrupt file that breaks git clone on windows ([ccff140](https://github.com/mrcjkb/rustaceanvim/commit/ccff14065096c8978c431944f0f0db16db952c7b))
* remove luajit requirement ([#512](https://github.com/mrcjkb/rustaceanvim/issues/512)) ([9db87de](https://github.com/mrcjkb/rustaceanvim/commit/9db87deb7b00d64466b56afff645756530db1c03))
* **renderDiagnostic:** hover closes immediately if `auto_focus` disabled ([d0cec19](https://github.com/mrcjkb/rustaceanvim/commit/d0cec198269c35485b12d9dd908c25e45a79231d))
* **runnables:** `cd` into directory with spaces not working ([#214](https://github.com/mrcjkb/rustaceanvim/issues/214)) ([b42e081](https://github.com/mrcjkb/rustaceanvim/commit/b42e08147e7e10124513c84c0f0f2bb6e53f6e59))
* **runnables:** broken `last` subcommand ([#63](https://github.com/mrcjkb/rustaceanvim/issues/63)) ([1e1ebeb](https://github.com/mrcjkb/rustaceanvim/commit/1e1ebeb43f356f9b5a9876963b70dd9bde8095bb))
* **rustc:** windows support ([029ae8e](https://github.com/mrcjkb/rustaceanvim/commit/029ae8e0c3ba792950d48ea1e4d9af339318ea06))
* **ssr:** broken when command contains spaces ([#106](https://github.com/mrcjkb/rustaceanvim/issues/106)) ([ddc6288](https://github.com/mrcjkb/rustaceanvim/commit/ddc6288c4e414475764518a9b88f8c339b61449f))
* **ssr:** make query optional ([d78a6c7](https://github.com/mrcjkb/rustaceanvim/commit/d78a6c70da6d22ada3fbe2d48af4c598b5bcd235))
* **termopen:** "&lt;Esc&gt;" to close buffer not silent ([#392](https://github.com/mrcjkb/rustaceanvim/issues/392)) ([253ce04](https://github.com/mrcjkb/rustaceanvim/commit/253ce043dcb41d92a6d99a317c9fab61e3df6f47))
* **testables,neotest:** don't use nextest if disabled in the config ([08ddf66](https://github.com/mrcjkb/rustaceanvim/commit/08ddf66e28c5d268259bf7307cd432a4f3868dcb))
* **testables:** prevent using nextest for doctests ([#246](https://github.com/mrcjkb/rustaceanvim/issues/246)) ([520d88d](https://github.com/mrcjkb/rustaceanvim/commit/520d88d53d4446b256d3b5029bc225667c7e190d))
* **testables:** support aliases for `test_executor` and `crate_test_executor` ([e016e69](https://github.com/mrcjkb/rustaceanvim/commit/e016e6912e814fbaa063cd789ca5ca22df3f70db))
* **testables:** support neotest executor when using nextest ([c369a48](https://github.com/mrcjkb/rustaceanvim/commit/c369a485f733ce3a57620c7251468722241de519))
* **ui:** `float_win_config.border` not applied to code action group ([#364](https://github.com/mrcjkb/rustaceanvim/issues/364)) ([efccc7d](https://github.com/mrcjkb/rustaceanvim/commit/efccc7d7c42e0849a6c85bfd6a8d746729cf08b5))
* **ui:** `nil` safety in codeAction Group ([#487](https://github.com/mrcjkb/rustaceanvim/issues/487)) ([6d994af](https://github.com/mrcjkb/rustaceanvim/commit/6d994afc21a820456b7819a65466a01ee9b5657d))
* **ui:** buggy concealing of elements in rendered diagnostics ([#281](https://github.com/mrcjkb/rustaceanvim/issues/281)) ([c787f5b](https://github.com/mrcjkb/rustaceanvim/commit/c787f5b0fafc29f9487b1314b19515451fd990e7))
* **ui:** don't override Neovim defaults in default `float_win_config` ([1c3d3a7](https://github.com/mrcjkb/rustaceanvim/commit/1c3d3a75bebcb16df2a093b147ba498185e4ab17))
* **ui:** explicitly disable signcolumn for floating windows ([#264](https://github.com/mrcjkb/rustaceanvim/issues/264)) ([b5342fc](https://github.com/mrcjkb/rustaceanvim/commit/b5342fcd1f8dc694d375983c60df928b58a02eb4))
* use new workspace reload command ([#36](https://github.com/mrcjkb/rustaceanvim/issues/36)) ([b920375](https://github.com/mrcjkb/rustaceanvim/commit/b9203750b252ca6eba0fd29014ac64ec52f7b675))
* **vimdoc:** actually include tags file ([5d0cec6](https://github.com/mrcjkb/rustaceanvim/commit/5d0cec60d3ff20587c77e0851c919f89068da355))
* **windows:** correct path for codelldb.exe ([#101](https://github.com/mrcjkb/rustaceanvim/issues/101)) ([52d4e9a](https://github.com/mrcjkb/rustaceanvim/commit/52d4e9a78fd5847c278a1be2c64b08ace400ecf9))
* **windows:** remove empty file causing git clone to fail ([b7c8171](https://github.com/mrcjkb/rustaceanvim/commit/b7c8171b1a496e20a2906bf74d1a260f802932d3))
* work around bug in Nushell on Windows ([#564](https://github.com/mrcjkb/rustaceanvim/issues/564)) ([59f15ef](https://github.com/mrcjkb/rustaceanvim/commit/59f15efe7fcc6be5de57319764911849597f92a3))


### Performance Improvements

* **dap:** only set `autoload_configurations = true` for Neovim &gt;= 0.10 ([acddc41](https://github.com/mrcjkb/rustaceanvim/commit/acddc41b32d31c845ed523b2c962b29e50a03dee))
* **dap:** use cached source map lldb commands and library path ([87c3b2d](https://github.com/mrcjkb/rustaceanvim/commit/87c3b2d7b1e27c05d3e2b5b16bd9f49355701508))
* don't run `ftplugin/rust.lua` more than once per buffer ([a503d05](https://github.com/mrcjkb/rustaceanvim/commit/a503d05212bf2ae2f5feb788e371c5cbddd100e5))
* **lsp:** defer attaching client to `BufEnter` ([#409](https://github.com/mrcjkb/rustaceanvim/issues/409)) ([90bfbc5](https://github.com/mrcjkb/rustaceanvim/commit/90bfbc588fef7e44d82e5aba8dfc787e8d3f5d1a))
* optimize target_arch switching ([#548](https://github.com/mrcjkb/rustaceanvim/issues/548)) ([6c4c8d8](https://github.com/mrcjkb/rustaceanvim/commit/6c4c8d82db26b9deab655ca4f75f526652a0de8a))
* replace `vim.g` with `_G` in init check ([7c3a2c8](https://github.com/mrcjkb/rustaceanvim/commit/7c3a2c8c5e422f17827ec509cfecff11dbd8e296))


### Reverts

* **dap:** redirect stdout to a temp file ([#232](https://github.com/mrcjkb/rustaceanvim/issues/232)) ([1e95699](https://github.com/mrcjkb/rustaceanvim/commit/1e956999e45cda8a65cef625c46102495b3eab40))
* don't run ftplugin/rust.lua more than once per buffer ([5fb048d](https://github.com/mrcjkb/rustaceanvim/commit/5fb048d9a59872547f9ed94b964cf4b35ed6c2fc))
* fix update.yml ([4237924](https://github.com/mrcjkb/rustaceanvim/commit/4237924685ad17ed5178ab57c5814db5f4717ee3))
* **lsp:** defer attaching client to `BufEnter` ([#409](https://github.com/mrcjkb/rustaceanvim/issues/409)) ([9d3ee35](https://github.com/mrcjkb/rustaceanvim/commit/9d3ee35b62d84f0657ef2202ebde132df5bc6cf9))
* replace `vim.g` with `_G` in init check ([1e18fdb](https://github.com/mrcjkb/rustaceanvim/commit/1e18fdb541c6e4a0d2d30014c7f6e3ce0666205a))


### Code Refactoring

* **docs:** rename types in LuaCATS annotations and vimdoc. ([c2a8fcb](https://github.com/mrcjkb/rustaceanvim/commit/c2a8fcb232e83f192259af7e1342fb9bc9547ed9))
* drop neovim 0.9 compatibility layer ([dd4c180](https://github.com/mrcjkb/rustaceanvim/commit/dd4c180f0136f9b938d51940b451e785d47a6874))

## [5.13.2](https://github.com/mrcjkb/rustaceanvim/compare/v5.13.1...v5.13.2) (2024-11-09)


### Bug Fixes

* work around bug in Nushell on Windows ([#564](https://github.com/mrcjkb/rustaceanvim/issues/564)) ([59f15ef](https://github.com/mrcjkb/rustaceanvim/commit/59f15efe7fcc6be5de57319764911849597f92a3))

## [5.13.1](https://github.com/mrcjkb/rustaceanvim/compare/v5.13.0...v5.13.1) (2024-10-28)


### Performance Improvements

* optimize target_arch switching ([#548](https://github.com/mrcjkb/rustaceanvim/issues/548)) ([6c4c8d8](https://github.com/mrcjkb/rustaceanvim/commit/6c4c8d82db26b9deab655ca4f75f526652a0de8a))

## [5.13.0](https://github.com/mrcjkb/rustaceanvim/compare/v5.12.0...v5.13.0) (2024-10-17)


### Features

* **lsp:** target architecture switching command for `RustAnalyzer` ([#541](https://github.com/mrcjkb/rustaceanvim/issues/541)) ([95715b2](https://github.com/mrcjkb/rustaceanvim/commit/95715b28c87b4cb3a8a38e063e2aa5cd3a8024d7))


### Bug Fixes

* remove corrupt file that breaks git clone on windows ([ccff140](https://github.com/mrcjkb/rustaceanvim/commit/ccff14065096c8978c431944f0f0db16db952c7b))

## [5.12.0](https://github.com/mrcjkb/rustaceanvim/compare/v5.11.0...v5.12.0) (2024-10-15)


### Features

* **config:** health check reports for .vscode/settings.json ([#539](https://github.com/mrcjkb/rustaceanvim/issues/539)) ([cb31013](https://github.com/mrcjkb/rustaceanvim/commit/cb31013a983faec6339d3bf6aad782da8fc7e111))

## [5.11.0](https://github.com/mrcjkb/rustaceanvim/compare/v5.10.1...v5.11.0) (2024-10-01)


### Features

* **lsp:** preserve cursor position for move_item command ([#532](https://github.com/mrcjkb/rustaceanvim/issues/532)) ([a07bb0d](https://github.com/mrcjkb/rustaceanvim/commit/a07bb0d256d1f9693ae8fb96dbcc5350b18f2978))

## [5.10.1](https://github.com/mrcjkb/rustaceanvim/compare/v5.10.0...v5.10.1) (2024-09-27)


### Bug Fixes

* **windows:** remove empty file causing git clone to fail ([b7c8171](https://github.com/mrcjkb/rustaceanvim/commit/b7c8171b1a496e20a2906bf74d1a260f802932d3))

## [5.10.0](https://github.com/mrcjkb/rustaceanvim/compare/v5.9.0...v5.10.0) (2024-09-27)


### Features

* add hint on how to configure/disable server status notifications ([711e25f](https://github.com/mrcjkb/rustaceanvim/commit/711e25fe11b6e72fbeda52d9d81b85a5aa3a81ab))

## [5.9.0](https://github.com/mrcjkb/rustaceanvim/compare/v5.8.1...v5.9.0) (2024-09-23)


### Features

* **lsp:** only notify on server status error by default ([#519](https://github.com/mrcjkb/rustaceanvim/issues/519)) ([360ac5c](https://github.com/mrcjkb/rustaceanvim/commit/360ac5c80f299f282cbb1967bbfe5aa1e1c6e66e))

## [5.8.1](https://github.com/mrcjkb/rustaceanvim/compare/v5.8.0...v5.8.1) (2024-09-21)


### Bug Fixes

* **lsp:** update deprecated API calls ([#514](https://github.com/mrcjkb/rustaceanvim/issues/514)) ([9a36905](https://github.com/mrcjkb/rustaceanvim/commit/9a369055aebd0411a11600f7cfd5c9b39c751eaa))

## [5.8.0](https://github.com/mrcjkb/rustaceanvim/compare/5.7.0...v5.8.0) (2024-09-20)


### Features

* **lsp:** `<Plug>` mapping for hover actions ([#510](https://github.com/mrcjkb/rustaceanvim/issues/510)) ([b52bbc4](https://github.com/mrcjkb/rustaceanvim/commit/b52bbc4bb0e50bf7da65b2695e1d602344877858))


### Bug Fixes

* remove luajit requirement ([#512](https://github.com/mrcjkb/rustaceanvim/issues/512)) ([9db87de](https://github.com/mrcjkb/rustaceanvim/commit/9db87deb7b00d64466b56afff645756530db1c03))

## [5.7.0]

### Added

- LSP: More information in unhealthy rust-analyzer notifications.
  Thanks [@edevil](https://github.com/edevil)!

## [5.6.0] - 2024-09-18

### Added

- LSP: Notify if rust-analyzer is not healthy.

## [5.5.0] - 2024-09-16

### Changed

- Deprecate `rust-analyzer.json` in favour of `.vscode/settings.json`
  or `:h exrc`.

## [5.4.2] - 2024-09-12

### Fixed

- When adding DAP configurations
  (`vim.g.rustaceanvim.dap.autoload_configurations = true`, default),
  wait for compilation before spawning another process for the next compilation.

## [5.4.1] - 2024-09-10

### Fixed

- Vim help docs: Actually include tags file.

## [5.4.0] - 2024-09-10

### Added

- Vim help docs: Include tags.

## [5.3.0] - 2024-09-10

### Added

- DAP: Use integrated terminal for lldb-dap by default
  Thanks [@adonis0147](https://github.com/adonis0147)!

## [5.2.3] - 2024-09-04

### Fixed

- LSP: Copy settings to `init_options` when starting the client
  to match VSCode.
  Thanks [@cormacrelf](https://github.com/cormacrelf)!

## [5.2.2] - 2024-08-26

### Fixed

- UI: `nil` safety in codeAction Group.
  Thanks [@dsully](https://github.com/dsully)!

## [5.2.1] - 2024-08-13

### Fixed

- LSP: rust-analyzer crash on `flyCheck [clear|cancel]` [[#465](https://github.com/mrcjkb/rustaceanvim/issues/465)].
  Thanks [@jannes](https://github.com/jannes)!

## [5.2.0] - 2024-08-06

### Added

- Load rust-analyzer settings from `.vscode/settings.json` by default.
  Can be disabled by setting `vim.g.rustaceanvim.server.load_vscode_settings`.
  This was introduced as an experimental feature in version 4.14.0.

## [5.1.5] - 2024-08-05

### Fixed

- Health: Warn if no debug adapters have been detected.

## [5.1.4] - 2024-08-02

### Fixed

- LSP (runnables/quickfix executor): Quickfix list populated with a single line.

## [5.1.3] - 2024-08-02

### Fixed

- LSP (runnables/quickfix executor): Always add both `stdout` and `stderr`
  to the quickfix list.

## [5.1.2] - 2024-08-02

### Fixed

- DAP: Autoload new configurations in `on_attach` [[#466](https://github.com/mrcjkb/rustaceanvim/issues/466)].

## [5.1.1] - 2024-07-29

### Fixed

- Neotest: One test failure caused all succeeding tests to be marked as failed
  when using cargo-nextest 0.9.7 [[#460](https://github.com/mrcjkb/rustaceanvim/issues/460)].
- Neotest: Disable ansi colour coding in output to ensure output can be parsed.
- `Rustc unpretty`: Support Windows.
- Auto-detect the `rustc` edition.
  This deprecates the `vim.g.rustaceanvim.tools.rustc.edition` option
  in favour of `vim.g.rustaceanvim.tools.rustc.default_edition`.

## [5.1.0] - 2024-07-27

### Added

- LSP: Added colored ansi code diagnostic to floating and split windows
  for `RustLsp renderDiagnostic`.
  Thanks [@xzbdmw](https://github.com/xzbdmw)!

## [5.0.0] - 2024-07-26

### BREAKING CHANGES

- Require Neovim `>= 0.10.0`.
- Rename types in LuaCATS annotations and vimdoc.

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
