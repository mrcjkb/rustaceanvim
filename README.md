<!-- markdownlint-disable -->
<br />
<div align="center">
  <a href="https://github.com/mrcjkb/rustaceanvim">
    <img src="./rustaceanvim.svg" alt="rustaceanvim">
  </a>
  <p align="center">
    <br />
    <a href="./doc/rustaceanvim.txt"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/mrcjkb/rustaceanvim/issues/new?assignees=&labels=bug&projects=&template=bug_report.yml">Report Bug</a>
    ·
    <a href="https://github.com/mrcjkb/rustaceanvim/discussions/new?category=ideas">Request Feature</a>
    ·
    <a href="https://github.com/mrcjkb/rustaceanvim/discussions/new?category=q-a">Ask Question</a>
  </p>
  <p>
    <strong>
      Supercharge your Rust experience in <a href="https://neovim.io/">Neovim</a>!<br />
      A heavily modified fork of <a href="https://github.com/simrat39/rust-tools.nvim">rust-tools.nvim</a><br />
    </strong>
  </p>
  <p>🦀</p>
	
[![Neovim][neovim-shield]][neovim-url]
[![Lua][lua-shield]][lua-url]
[![Rust][rust-shield]][rust-url]
[![Nix][nix-shield]][nix-url]

[![GPL2 License][license-shield]][license-url]
[![Issues][issues-shield]][issues-url]
[![Build Status][ci-shield]][ci-url]
[![LuaRocks][luarocks-shield]][luarocks-url]
</div>
<!-- markdownlint-restore -->

> [!NOTE]
>
> - Just works. [No need to call `setup`!](https://mrcjkb.dev/posts/2023-08-22-setup.html)
> - No dependency on `lspconfig`.
> - Lazy initialization by design.

## :link: Quick Links

- [:pencil: Prerequisites](#pencil-prerequisites)
- [:inbox_tray: Installation](#inbox_tray-installation)
- [:zap: Quick setup](#zap-quick-setup)
- [:books: Usage / Features](#books-usage--features)
- [:gear: Advanced configuration](#gear-advanced-configuration)
- [:stethoscope: Troubleshooting](#stethoscope-troubleshooting)
- [:left_speech_bubble: FAQ](#left_speech_bubble-faq)
- [:rowboat: Migrating from rust-tools](https://github.com/mrcjkb/rustaceanvim/discussions/122)

## :grey_question: Do I need rustaceanvim

If you are starting out with Rust, Neovim's built-in LSP client API
(see [`:h lsp`](https://neovim.io/doc/user/lsp.html)) or
[`nvim-lspconfig.rust_analyzer`](https://github.com/neovim/nvim-lspconfig)
is probably enough for you.
It provides the lowest common denominator of LSP support.
This plugin is for those who would like [additional non-standard features](#books-usage--features)
that are specific to rust-analyzer.

## :pencil: Prerequisites

### Required

- `neovim >= 0.10`
- [`rust-analyzer`](https://rust-analyzer.github.io/)

### Optional

- [`dot` from `graphviz`](https://graphviz.org/doc/info/lang.html),
  for crate graphs.
- [`cargo`](https://doc.rust-lang.org/cargo/),
  required for Cargo projects.
- A debug adapter (e.g. [`lldb`](https://lldb.llvm.org/)
  or [`codelldb`](https://github.com/vadimcn/codelldb))
  and [`nvim-dap`](https://github.com/mfussenegger/nvim-dap),
  required for debugging.
- A tree-sitter parser for Rust (required for the `:Rustc unpretty` command).
  Can be installed using [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter),
  which also provides highlights, etc.

## :inbox_tray: Installation

### [`rocks.nvim`](https://github.com/nvim-neorocks/rocks.nvim)

```vim
:Rocks install rustaceanvim
```

### [`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
{
  'mrcjkb/rustaceanvim',
  version = '^5', -- Recommended
  lazy = false, -- This plugin is already lazy
}
```

>[!TIP]
>
>It is suggested to pin to tagged releases if you would like to avoid breaking changes.

To manually generate documentation, use `:helptags ALL`.

### Nix

For Nix users with flakes enabled, this project provides outputs in the
form of a package and an overlay.
It is also available in `nixpkgs`.

Look at the configuration information below to get started.

## :zap: Quick Setup

This plugin automatically configures the `rust-analyzer` builtin LSP
client and integrates with other Rust tools.
See the [Usage / Features](#books-usage--features) section for more info.

>[!WARNING]
>
> Do not call the [`nvim-lspconfig.rust_analyzer`](https://github.com/neovim/nvim-lspconfig)
> setup or set up the LSP client for `rust-analyzer` manually,
> as doing so may cause conflicts.

This is a filetype plugin that works out of the box,
so there is no need to call a `setup` function or configure anything
to get this plugin working.

You will most likely want to add some keymaps.
Most keymaps are only useful in rust files,
so I suggest you define them in `~/.config/nvim/after/ftplugin/rust.lua`[^1]

[^1]: See [`:help base-directories`](https://neovim.io/doc/user/starting.html#base-directories)

Example:

```lua
local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set(
  "n", 
  "<leader>a", 
  function()
    vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
    -- or vim.lsp.buf.codeAction() if you don't want grouping.
  end,
  { silent = true, buffer = bufnr }
)
vim.keymap.set(
  "n", 
  "K",  -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
  function()
    vim.cmd.RustLsp({'hover', 'actions'})
  end,
  { silent = true, buffer = bufnr }
)
```

>[!TIP]
>
> - For more LSP related keymaps, [see the `nvim-lspconfig` suggestions](https://github.com/neovim/nvim-lspconfig#suggested-configuration).
> - If you want to share keymaps with `nvim-lspconfig`,
>   you can also use the `vim.g.rustaceanvim.server.on_attach` function,
>   or an `LspAttach` autocommand.
> - See the [Advanced configuration](#gear-advanced-configuration) section
>   or `:h rustaceanvim.config` for more configuration options.
<!-- markdownlint-disable -->
<!-- markdownlint-restore -->
>[!IMPORTANT]
>
> - Do **not** set `vim.g.rustaceanvim`
>   in `after/ftplugin/rust.lua`, as
>   the file is sourced after the plugin
>   is initialized.

## :books: Usage / Features

<!-- markdownlint-disable -->
<details>
  <summary>
	<b>Debugging</b>
  </summary>

  - `debuggables` opens a prompt to select from available targets.
  - `debug` searches for a target at the current cursor position.
  
  
  ```vim
  :RustLsp[!] debuggables {args[]}?
  :RustLsp[!] debug {args[]}?
  ```
  ```lua
  vim.cmd.RustLsp('debug')
  vim.cmd.RustLsp('debuggables')
  -- or, to run the previous debuggable:
  vim.cmd.RustLsp { 'debuggables', bang = true }
  -- or, to override the executable's args:
  vim.cmd.RustLsp {'debuggables', 'arg1', 'arg2' }
  ```

  Calling the command with a bang `!` will rerun the last debuggable.

  Requires:

  - [`nvim-dap`](https://github.com/mfussenegger/nvim-dap)
    (Please read the plugin's documentation).
  - A debug adapter (e.g. [`lldb-dap`](https://lldb.llvm.org/resources/lldbdap)
    or [`codelldb`](https://github.com/vadimcn/codelldb)).

  By default, this plugin will silently attempt to autoload `nvim-dap`
  configurations when the LSP client attaches.
  You can call them with `require('dap').continue()` or `:DapContinue` once
  they have been loaded. The feature can be disabled by setting
  `vim.g.rustaceanvim.dap.autoload_configurations = false`.

  - `:RustLsp debuggables` will only load debug configurations
    created by `rust-analyzer`.
  - `require('dap').continue()` will load all Rust debug configurations,
    including those specified in a `.vscode/launch.json`
    (see [`:h dap-launch.json`](https://github.com/mfussenegger/nvim-dap/blob/9adbfdca13afbe646d09a8d7a86d5d031fb9c5a5/doc/dap.txt#L316)).
  - Note that rustaceanvim may only be able to load DAP configurations
    when rust-analyzer has finished initializing (which may be after
    the client attaches, in large projects). This means that the
    DAP configurations may not be loaded immediately upon startup.

  ![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/ce17d228-ae0a-416a-8159-fe095a85dcb7)

</details>

<details>
  <summary>
	<b>Runnables</b>
  </summary>

  - `runnables` opens a prompt to select from available targets.
  - `run` searches for a target at the current cursor position.
  
  ```vim
  :RustLsp[!] runnables {args[]}?
  :RustLsp[!] run {args[]}?
  ```
  ```lua
  vim.cmd.RustLsp('run') 
  vim.cmd.RustLsp('runnables')
  -- or, to run the previous runnable:
  vim.cmd.RustLsp { 'runnables', bang = true }
  -- or, to override the executable's args:
  vim.cmd.RustLsp {'runnables', 'arg1', 'arg2' }
  ```

  Calling the command with a bang `!` will rerun the last runnable.

  ![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/95183192-5669-4a07-804b-83f67831be57)


</details>

<details>
  <summary>
	<b>Testables and failed test diagnostics</b>
  </summary>

  If you are using Neovim >= 0.10, you can set the `vim.g.rustaceanvim.tools.test_executor`
  option to `'background'`, and this plugin will run tests in the background,
  parse the results, and - if possible - display failed tests as diagnostics.

  This is also possible in Neovim 0.9, but tests won't be run in the background,
  and will block the UI.
  
  ```vim
  :RustLsp[!] testables {args[]}?
  ```
  ```lua
  vim.cmd.RustLsp('testables')
  -- or, to run the previous testables:
  vim.cmd.RustLsp { 'testables', bang = true }
  -- or, to override the executable's args:
  vim.cmd.RustLsp {'testables', 'arg1', 'arg2' }
  ```

  Calling the command with a bang `!` will rerun the last testable.

  ![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/b3639b7a-105e-49de-9bdc-9c88e8e508a2)

</details>

<details>
  <summary>
	<b>Neotest integration</b>
  </summary>

  This plugin provides a [neotest](https://github.com/nvim-neotest/neotest) adapter,
  which you can add to neotest as follows:
  
  ```lua
  require('neotest').setup {
      -- ...,
      adapters = {
        -- ...,
        require('rustaceanvim.neotest')
      },
  }
  ```

  Note: If you use rustaceanvim's neotest adapter,
  do not add [neotest-rust](https://github.com/rouge8/neotest-rust).

  Here is a comparison between rustaceanvim's adapter and neotest-rust:

  |  | rustaceanvim | neotest-rust |
  |:--|:--|:--|
  | Test discovery | rust-analyzer (LSP) | tree-sitter |
  | Command construction | rust-analyzer (LSP) | tree-sitter |
  | DAP strategy | Automatic DAP detection (reuses `debuggables`); overridable with `vim.g.rustaceanvim.dap` | Defaults to `codelldb`; manual configuration |
  | Test runner | `cargo` or `cargo-nextest`, if detected | `cargo-nextest` |

  If you configure rustaceanvim to use neotest, the `tools.test_executor`
  will default to using neotest for `testables` and `runnables` that are tests.

  ![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/b734fdb6-3c8a-492b-9b39-bb238d7cd7b1)

</details>

<details>
  <summary>
	<b>Expand macros recursively</b>
  </summary>
  
  ```vim
  :RustLsp expandMacro
  ```
  ```lua
  vim.cmd.RustLsp('expandMacro')
  ```
  ![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/477d9e58-74b0-42ff-87ca-2fef34d06db3)
</details>

<details>
  <summary>
	<b>Rebuild proc macros</b>
  </summary>
  
  ```vim
  :RustLsp rebuildProcMacros
  ```
  ```lua
  vim.cmd.RustLsp('rebuildProcMacros')
  ```

</details>

<details>
  <summary>
	<b>Move item up/down</b>
  </summary>
  
  ```vim
  :RustLsp moveItem {up|down}
  ```
  ```lua
  vim.cmd.RustLsp { 'moveItem',  'up' }
  vim.cmd.RustLsp { 'moveItem',  'down' }
  ```
</details>

<details>
  <summary>
	<b>Grouped code actions</b>
  </summary>
  
 Sometimes, rust-analyzer groups code actions by category,
 which is not supported by Neovim's built-in `vim.lsp.buf.codeAction`.
 This plugin provides a command with a UI that does:

 ```vim
 :RustLsp codeAction
 ```
 ```lua
 vim.cmd.RustLsp('codeAction')
 ```

 If you set the option `vim.g.rustaceanvim.tools.code_actions.ui_select_fallback`
 to `true` (defaults to `false`), it will fall back to `vim.ui.select`
 if there are no grouped code actions.

![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/866d3cb1-8e56-4380-8c03-812386441f47)

</details>

<details>
  <summary>
	<b>Hover actions</b>
  </summary>
  
 Note: To activate hover actions, run the command twice.
 This will move you into the window, then press enter on the selection you want.
 Alternatively, you can set `auto_focus` to `true` in your config and you will 
 automatically enter the hover actions window.

 ```vim
 :RustLsp hover actions
 ```
 ```lua
 vim.cmd.RustLsp { 'hover', 'actions' }
 ```

 You can invoke a hover action by switching to the hover window and entering `<CR>`
 on the respective line, or with a keymap for the `<Plug>RustHoverAction` mapping,
 which accepts a `<count>` prefix as the (1-based) index of the hover action to invoke.
 
 For example, if you set the following keymap:
 
 ```lua
 vim.keymap.set('n', '<space>a', '<Plug>RustHoverAction')
 ```
 
 you can invoke the third hover action with `3<space>a`.

![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/c7b6c730-4439-47b0-9a75-7ea4e6831f7a)

</details>

<details>
  <summary>
	<b>Hover range</b>
  </summary>

  ```vim
  :RustLsp hover range
  ```
  ```lua
  vim.cmd.RustLsp { 'hover', 'range' }
  ```
</details>

<details>
  <summary>
	<b>Explain errors</b>
  </summary>

  Display a hover window with explanations from the [rust error codes index](https://doc.rust-lang.org/error_codes/error-index.html)
  over error diagnostics (if they have an error code).
  
  ```vim
  :RustLsp explainError {cycle?|current?}
  ```
  ```lua
  vim.cmd.RustLsp('explainError') -- default to 'cycle'
  vim.cmd.RustLsp({ 'explainError', 'cycle' })
  vim.cmd.RustLsp({ 'explainError', 'current' })
  ```

  - If called with `cycle` or no args:
    Like `vim.diagnostic.goto_next`,
    `explainError` will cycle diagnostics,
    starting at the cursor position,
    until it can find a diagnostic with an error code.
    
  - If called with `current`:
    Searches for diagnostics only in the
    current cursor line.

![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/bac9b31c-22ca-40c4-bfd3-b8c5ba4cc49a)

</details>

<details>
  <summary>
	<b>Render diagnostics</b>
  </summary>

  Display a hover window with the rendered diagnostic, as displayed
  during `cargo build`.
  Useful for solving bugs around borrowing and generics,
  as it consolidates the important bits (sometimes across files)
  together.
  
  ```vim
  :RustLsp renderDiagnostic {cycle?|current?}
  ```
  ```lua
  vim.cmd.RustLsp('renderDiagnostic') -- defaults to 'cycle'
  vim.cmd.RustLsp({ 'renderDiagnostic', 'cycle' })
  vim.cmd.RustLsp({ 'renderDiagnostic', 'current' })
  ```

  - If called with `cycle` or no args:
    Like `vim.diagnostic.goto_next`,
    `renderDiagnostic` will cycle diagnostics,
    starting at the cursor position,
    until it can find a diagnostic with rendered data.
    
  - If called with `current`:
    Searches for diagnostics only in the
    current cursor line.

![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/a972c6b6-c504-4c2a-8380-53451bb8c2de)

</details>

<details>
  <summary>
	<b>Jump to related diagnostics</b>
  </summary>

  Sometimes, rust-analyzer provides related diagnostics in multiple locations.
  Using the `relatedDiagnostics` subcommand, you can navigate between them.
  If a diagnostic has more than one related diagnostic, this will populate the quickfix list.

  ```vim
  :RustLsp relatedDiagnostics
  ```
  ```lua
  vim.cmd.RustLsp('relatedDiagnostics')
  ```

![](https://github.com/user-attachments/assets/26695f41-2d9d-4250-82fa-fea867fd9432)

</details>

<details>
  <summary>
	<b>Open Cargo.toml</b>
  </summary>
  
  ```vim
  :RustLsp openCargo
  ```
  ```lua
  vim.cmd.RustLsp('openCargo')
  ```
</details>

<details>
  <summary>
	<b>Open docs.rs documentation</b>
  </summary>

  Open docs.rs documentation for the symbol under the cursor.
  
  ```vim
  :RustLsp openDocs
  ```
  ```lua
  vim.cmd.RustLsp('openDocs')
  ```
</details>

<details>
  <summary>
	<b>Parent Module</b>
  </summary>
  
  ```vim
  :RustLsp parentModule
  ```
  ```lua
  vim.cmd.RustLsp('parentModule')
  ```
</details>

<details>
  <summary>
	<b>Filtered workspace symbol searches</b>
  </summary>

  rust-analyzer supports filtering workspace symbol searches.
  
  ```vim
  :RustLsp[!] workspaceSymbol {onlyTypes?|allSymbols?} {query?}
  ```
  ```lua
  vim.cmd.RustLsp('workspaceSymbol')
  -- or
  vim.cmd.RustLsp { 
    'workspaceSymbol', 
    '<onlyTypes|allSymbols>' --[[ optional ]], 
    '<query>' --[[ optional ]], 
    bang = true --[[ optional ]]
  }
  ```

  - Calling the command with a bang `!` will include dependencies in the search.
  - You can also influence the behaviour of [`vim.lsp.buf.workspace_symbol()`](https://neovim.io/doc/user/lsp.html#vim.lsp.buf.workspace_symbol())
by setting the rust-analyzer
`workspace.symbol.search` server option.

</details>

<details>
  <summary>
	<b>Join lines</b>
  </summary>

  Join selected lines into one, smartly fixing up whitespace, trailing commas, and braces.
  Works with individual lines in normal mode and multiple lines in visual mode.
  
  ```vim
  :RustLsp joinLines
  ```
  ```lua
  vim.cmd.RustLsp('joinLines')
  ```

  ![](https://user-images.githubusercontent.com/1711539/124515923-4504e800-dde9-11eb-8d58-d97945a1a785.gif)
  
</details>

<details>
  <summary>
	<b>Structural search replace</b>
  </summary>

  - Searches the entire buffer in normal mode.
  - Searches the selection in visual mode.
  
  ```vim
  :RustLsp ssr {query}
  ```
  ```lua
  vim.cmd.RustLsp { 'ssr', '<query>' --[[ optional ]] }
  ```

  ![tty](https://github.com/mrcjkb/rustaceanvim/assets/12857160/b61fbc56-ab53-48e6-bfdd-eb8d4de28795)

</details>

<details>
  <summary>
	<b>View crate graph</b>
  </summary>
  
  ```vim
  :RustLsp crateGraph {backend {output}}
  ```
  ```lua
  vim.cmd.RustLsp { 'crateGraph', '[backend]', '[output]' }
  ```

  Requires:

  - [`dot` from `graphviz`](https://graphviz.org/doc/info/lang.html)
    
</details>

<details>
  <summary>
	<b>View syntax tree</b>
  </summary>
  
  ```vim
  :RustLsp syntaxTree
  ```
  ```lua
  vim.cmd.RustLsp('syntaxTree')
  ```

  ![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/c865a263-1568-41c7-a32b-bc4a34b198dc)

</details>

<details>
  <summary>
	<b>Fly check</b>
  </summary>

  Run `cargo check` or another compatible command (f.x. `clippy`) 
  in a background thread and provide LSP diagnostics based on 
  the output of the command.

  Useful in large projects where running `cargo check` on each save
  can be costly.
  
  ```vim
  :RustLsp flyCheck {run?|clear?|cancel?}
  ```
  ```lua
  vim.cmd.RustLsp('flyCheck') -- defaults to 'run'
  vim.cmd.RustLsp { 'flyCheck', 'run' }
  vim.cmd.RustLsp { 'flyCheck', 'clear' }
  vim.cmd.RustLsp { 'flyCheck', 'cancel' }
  ```

  > [!NOTE]
  >
  > This is only useful if you set the option,
  > `['rust-analzyer'].checkOnSave = false`.

</details>

<details>
  <summary>
	<b>View HIR / MIR</b>
  </summary>

  Opens a buffer with a textual representation of the HIR or MIR
  of the function containing the cursor.
  Useful for debugging or when working on rust-analyzer itself.
  
  ```vim
  :RustLsp view {hir|mir}
  ```
  ```lua
  vim.cmd.RustLsp { 'view', 'hir' }
  vim.cmd.RustLsp { 'view', 'mir' }
  ```
</details>

<details>
  <summary>
	<b>Rustc unpretty</b>
  </summary>

  Opens a buffer with a textual representation of the MIR or others things,
  of the function closest to the cursor.
  Achieves an experience similar to Rust Playground.

  NOTE: This currently requires a tree-sitter parser for Rust,
  and a nightly compiler toolchain.

  ```vim
  :Rustc unpretty {hir|mir|...}
  ```
  ```lua
  vim.cmd.Rustc { 'unpretty', 'hir' }
  vim.cmd.Rustc { 'unpretty', 'mir' }
  -- ...
  ```

  Requires:

  - A tree-sitter parser for Rust (required for the `:Rustc unpretty` command).
    Can be installed using [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter).

</details>

<details>
  <summary>
	<b>ra-multiplex</b>
  </summary>

  On Linux and MacOS, rustaceanvim can auto-detect and connect to a
  running [ra-multiplex](https://github.com/pr2502/ra-multiplex) server.
  By default, it will try to do so automatically if the `vim.g.rustaceanvim.server.cmd` 
  option is unset.
  See also `:h rustaceanvim.ra_multiplex`.

</details>
<!-- markdownlint-restore -->

## :gear: Advanced configuration

To modify the default configuration, set `vim.g.rustaceanvim`.

- See [`:h rustaceanvim`](./doc/rustaceanvim.txt) for a detailed
  documentation of all available configuration options.
  You may need to run `:helptags ALL` if the documentation has not been installed.
- The default configuration [can be found here (see `RustaceanDefaultConfig`)](./lua/rustaceanvim/config/internal.lua).
- For detailed descriptions of the language server configs,
  see the [`rust-analyzer` documentation](https://rust-analyzer.github.io/manual.html#configuration).

You only need to specify the keys
that you want to be changed, because defaults
are applied for keys that are not provided.

Example config:

```lua
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
  },
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
      -- you can also put keymaps in here
    end,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
      },
    },
  },
  -- DAP configuration
  dap = {
  },
}
```

> [!TIP]
>
> `vim.g.rustaceanvim` can also be a function that returns
> a table.

### Using `codelldb` for debugging

For Rust, `codelldb` from the [CodeLLDB VSCode extension](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
provides a better experience than `lldb`.
If you are using a distribution that lets you install the `codelldb`
executable, this plugin will automatically detect it and configure
itself to use it as a debug adapter.

Some examples:

- NixOS: [`vscode-extensions.vadimcn.vscode-lldb.adapter`](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/editors/vscode/extensions/vadimcn.vscode-lldb/default.nix#L134)
- This repository's Nix flake provides a `codelldb` package.
- Arch Linux: [`codelldb-bin` (AUR)](https://aur.archlinux.org/packages/codelldb-bin)
- Using [`mason.nvim`](https://github.com/williamboman/mason.nvim):
  `:MasonInstall codelldb`

If your distribution does not have a `codelldb` package,
you can configure it as follows:

1. Install the [CodeLLDB VSCode extension](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb).
1. Find out where it is installed.
   On Linux, this is typically in `$HOME/.vscode/extensions/`
1. Update your configuration:

```lua
vim.g.rustaceanvim = function()
  -- Update this path
  local extension_path = vim.env.HOME .. '/.vscode/extensions/vadimcn.vscode-lldb-1.10.0/'
  local codelldb_path = extension_path .. 'adapter/codelldb'
  local liblldb_path = extension_path .. 'lldb/lib/liblldb'
  local this_os = vim.uv.os_uname().sysname;

  -- The path is different on Windows
  if this_os:find "Windows" then
    codelldb_path = extension_path .. "adapter\\codelldb.exe"
    liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
  else
    -- The liblldb extension is .so for Linux and .dylib for MacOS
    liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
  end

  local cfg = require('rustaceanvim.config')
  return {
    dap = {
      adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
    },
  }
end
```

### How to dynamically load different `rust-analyzer` settings per project

By default, this plugin will look for a `.vscode/settings.json`[^2]
file and attempt to load it.
If the file does not exist, or it can't be decoded,
the `server.default_settings` will be used.

[^2]: See [this example](https://github.com/rust-analyzer/rust-project.json-example/blob/master/.vscode/settings.json)
      and the rust-analyzer [configuration manual](https://rust-analyzer.github.io/manual.html#configuration).
      Note that JSON5 is currently not supported by Neovim.

Another option is to use `:h exrc`.

## :stethoscope: Troubleshooting

### Health checks

For a health check, run `:checkhealth rustaceanvim`

### `rust-analyzer` log file

To open the `rust-analyzer` log file, run `:RustLsp logFile`.

### Minimal config

To troubleshoot this plugin with a minimal config in a temporary directory,
you can try [minimal.lua](./troubleshooting/minimal.lua).

```console
nvim -u minimal.lua
```

> [!NOTE]
>
> If you use Nix, you can run
> `nix run "github:mrcjkb/rustaceanvim#nvim-minimal-stable"`.
> or
> `nix run "github:mrcjkb/rustaceanvim#nvim-minimal-nightly"`.

If you cannot reproduce your issue with a minimal config,
it may be caused by another plugin,
or a setting of your plugin manager.
In this case, add additional plugins and configurations to `minimal.lua`,
until you can reproduce it.

### rust-analyzer troubleshooting

For issues related to rust-analyzer
(e.g. LSP features not working), see also
[the rust-analyzer troubleshooting guide](https://rust-analyzer.github.io/manual.html#troubleshooting).

### :left_speech_bubble: FAQ

#### Where are inlay hints / type hints?

As Neovim >= 0.10 supports inlay hints natively,
I have removed the code from this plugin.
See [`:h lsp-inlay_hint`](https://neovim.io/doc/user/lsp.html#lsp-inlay_hint)).

#### Can I display inlay hints to the end of the line?

You can use the [`nvim-lsp-endhints`](https://github.com/chrisgrieser/nvim-lsp-endhints)
plugin.

#### How to enable auto completion?

As of [#ff097f2091e7a970e5b12960683b4dade5563040](https://github.com/neovim/neovim/pull/27339),
Neovim has built-in completion based on the `triggerCharacters` sent by
language servers.
Omni completion is also available for a more traditional `vim`-like completion experience.

For more extensible and complex autocompletion setups,
you need a plugin such as [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp)
and a LSP completion source like [`cmp-nvim-lsp`](https://github.com/hrsh7th/cmp-nvim-lsp),
or you may use [`blink.cmp`](https://github.com/saghen/blink.cmp).
This plugin will automatically register the necessary client capabilities
if you have either `cmp-nvim-lsp` or `blink.cmp` installed.

#### I'm having issues with (auto)completion

rustaceanvim doesn't implement (auto)completion.
Issues with (auto)completion either come from another plugin or rust-analzyer.

#### mason.nvim and nvim-lspconfig

See [`:h rustaceanvim.mason`](./doc/mason.txt) for details about troubleshooting
mason.nvim and nvim-lspconfig issues, or configuring rustaceanvim to use
a rust-analyzer installation that is managed by mason.nvim.

#### I am not seeing diagnostics in a standalone file

rust-analyzer has limited support for standalone files.
Many diagnostics come from Cargo. If you're not in a Cargo project,
you won't see any Cargo diagnostics.

## :link: Related Projects

- [`rouge8/neotest-rust`](https://github.com/rouge8/neotest-rust)
  A [`neotest`](https://github.com/nvim-neotest/neotest)
  adapter for Rust, using [`cargo-nextest`](https://nexte.st/).
- [`Saecki/crates.nvim`](https://github.com/Saecki/crates.nvim)
- [`vxpm/ferris.nvim`](https://github.com/vxpm/ferris.nvim)
  Geared towards people who prefer manual LSP client configuration.
  Has some features that have not yet
  been implemented by this plugin.
- [`adaszko/tree_climber_rust.nvim`](https://github.com/adaszko/tree_climber_rust.nvim)
  tree-sitter powered incremental selection tailored for Rust.

## Inspiration

`rust-tools.nvim` draws inspiration from [`akinsho/flutter-tools.nvim`](https://github.com/akinsho/flutter-tools.nvim)

<!-- markdownlint-disable -->
<!-- prettier-ignore-end -->

<!-- MARKDOWN LINKS & IMAGES -->
[neovim-shield]: https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white
[neovim-url]: https://neovim.io/
[lua-shield]: https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white
[lua-url]: https://www.lua.org/
[nix-shield]: https://img.shields.io/badge/nix-0175C2?style=for-the-badge&logo=NixOS&logoColor=white
[nix-url]: https://nixos.org/
[rust-shield]: https://img.shields.io/badge/Rust-000000?style=for-the-badge&logo=rust&logoColor=white
[rust-url]: https://www.rust-lang.org/
[issues-shield]: https://img.shields.io/github/issues/mrcjkb/rustaceanvim.svg?style=for-the-badge
[issues-url]: https://github.com/mrcjkb/rustaceanvim/issues
[license-shield]: https://img.shields.io/github/license/mrcjkb/rustaceanvim.svg?style=for-the-badge
[license-url]: https://github.com/mrcjkb/rustaceanvim/blob/master/LICENSE
[ci-shield]: https://img.shields.io/github/actions/workflow/status/mrcjkb/rustaceanvim/nix-build.yml?style=for-the-badge
[ci-url]: https://github.com/mrcjkb/rustaceanvim/actions/workflows/nix-build.yml
[luarocks-shield]: https://img.shields.io/luarocks/v/MrcJkb/rustaceanvim?logo=lua&color=purple&style=for-the-badge
[luarocks-url]: https://luarocks.org/modules/MrcJkb/rustaceanvim
