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
    <a href="https://github.com/mrcjkb/rustaceanvim/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.yml">Request Feature</a>
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
</div>
<!-- markdownlint-restore -->

[![Neovim][neovim-shield]][neovim-url]
[![Lua][lua-shield]][lua-url]
[![Rust][rust-shield]][rust-url]
[![Nix][nix-shield]][nix-url]

[![GPL2 License][license-shield]][license-url]
[![Issues][issues-shield]][issues-url]
[![Build Status][ci-shield]][ci-url]
[![LuaRocks][luarocks-shield]][luarocks-url]

> [!NOTE]
>
> - Just works. [No need to call `setup`!](https://mrcjkb.dev/posts/2023-08-22-setup.html)
> - No dependency on `lspconfig`.
> - Lazy initialization by design.

## Quick Links

- [Installation](#installation)
- [Quick setup](#quick-setup)
- [Usage](#usage)
- [Advanced configuration](#advanced-configuration)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Migrating from rust-tools](https://github.com/mrcjkb/rustaceanvim/discussions/122)

## Prerequisites

### Required

- `neovim >= 0.9`
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

## Installation

This plugin is [available on LuaRocks][luarocks-url]:

[`:Rocks install rustaceanvim`](https://github.com/nvim-neorocks/rocks.nvim)

Example using [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
  'mrcjkb/rustaceanvim',
  version = '^3', -- Recommended
  ft = { 'rust' },
}
```

>[!NOTE]
>
>It is suggested to pin to tagged releases if you would like to avoid breaking changes.

To manually generate documentation, use `:helptags ALL`.

>[!NOTE]
>
> For NixOS users with flakes enabled, this project provides outputs in the
> form of a package and an overlay; use it as you wish in your NixOS or
> home-manager configuration.
> It is also available in `nixpkgs`.

Look at the configuration information below to get started.

## Quick Setup

This plugin automatically configures the `rust-analyzer` builtin LSP
client and integrates with other Rust tools.
See the [Usage](#usage) section for more info.

>[!WARNING]
>
> Do not call the [`nvim-lspconfig.rust_analyzer`](https://github.com/neovim/nvim-lspconfig)
> setup or set up the lsp client for `rust-analyzer` manually,
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
    vim.cmd.RustLsp('codeAction') 
  end,
  { silent = true, buffer = bufnr }
)
```

>[!NOTE]
>
> - For more LSP related keymaps, [see the `nvim-lspconfig` suggestions](https://github.com/neovim/nvim-lspconfig#suggested-configuration).
> - See the [Advanced configuration](#advanced-configuration) section
for more configuration options.

## Usage

<!-- markdownlint-disable -->
<details>
  <summary>
	<b>Debugging</b>
  </summary>
  
  ```vimscript
  :RustLsp debuggables [last?]
  ```
  ```lua
  vim.cmd.RustLsp {'debuggables', 'last' --[[ optional ]] }
  ```

  ![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/ce17d228-ae0a-416a-8159-fe095a85dcb7)

</details>

<details>
  <summary>
	<b>Runnables</b>
  </summary>
  
  ```vimscript
  :RustLsp runnables [last?]
  ```
  ```lua
  vim.cmd.RustLsp {'runnables', 'last' --[[ optional ]] }
  ```

  ![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/95183192-5669-4a07-804b-83f67831be57)


</details>

<details>
  <summary>
	<b>Expand Macros Recursively</b>
  </summary>
  
  ```vimscript
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
  
  ```vimscript
  :RustLsp rebuildProcMacros
  ```
  ```lua
  vim.cmd.RustLsp('rebuildProcMacros')
  ```

</details>

<details>
  <summary>
	<b>Move Item Up/Down</b>
  </summary>
  
  ```vimscript
  :RustLsp moveItem up
  :RustLsp moveItem down
  ```
  ```lua
  vim.cmd.RustLsp { 'moveItem',  'up' }
  vim.cmd.RustLsp { 'moveItem',  'down' }
  ```
</details>

<details>
  <summary>
	<b>Hover Actions</b>
  </summary>
  
 Note: To activate hover actions, run the command twice.
 This will move you into the window, then press enter on the selection you want.
 Alternatively, you can set `auto_focus` to `true` in your config and you will 
 automatically enter the hover actions window.

 ```vimscript
 :RustLsp hover actions
 ```
 ```lua
 vim.cmd.RustLsp { 'hover', 'actions' }
 ```

![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/c7b6c730-4439-47b0-9a75-7ea4e6831f7a)

</details>

<details>
  <summary>
	<b>Hover Range</b>
  </summary>

  ```vimscript
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
  
  ```vimscript
  :RustLsp explainError
  ```
  ```lua
  vim.cmd.RustLsp('explainError')
  ```

![](https://github.com/mrcjkb/rustaceanvim/assets/12857160/bac9b31c-22ca-40c4-bfd3-b8c5ba4cc49a)

</details>

<details>
  <summary>
	<b>Open Cargo.toml</b>
  </summary>
  
  ```vimscript
  :RustLsp openCargo
  ```
  ```lua
  vim.cmd.RustLsp('openCargo')
  ```
</details>

<details>
  <summary>
	<b>Parent Module</b>
  </summary>
  
  ```vimscript
  :RustLsp parentModule
  ```
  ```lua
  vim.cmd.RustLsp('parentModule')
  ```
</details>

<details>
  <summary>
	<b>Join Lines</b>
  </summary>

  Join selected lines into one, 
  smartly fixing up whitespace, 
  trailing commas, and braces.
  
  ```vimscript
  :RustLsp joinLines
  ```
  ```lua
  vim.cmd.RustLsp('joinLines')
  ```

  ![](https://user-images.githubusercontent.com/1711539/124515923-4504e800-dde9-11eb-8d58-d97945a1a785.gif)
  
</details>

<details>
  <summary>
	<b>Structural Search Replace</b>
  </summary>
  
  ```vimscript
  :RustLsp ssr [query]
  ```
  ```lua
  vim.cmd.RustLsp { 'ssr', '<query>' --[[ optional ]] }
  ```

  ![tty](https://github.com/mrcjkb/rustaceanvim/assets/12857160/b61fbc56-ab53-48e6-bfdd-eb8d4de28795)

</details>

<details>
  <summary>
	<b>View Crate Graph</b>
  </summary>
  
  ```vimscript
  :RustLsp crateGraph [backend [output]]
  ```
  ```lua
  vim.cmd.RustLsp { 'crateGraph', '[backend]', '[output]' }
  ```
</details>

<details>
  <summary>
	<b>View Syntax Tree</b>
  </summary>
  
  ```vimscript
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
  
  ```vimscript
  :RustLsp flyCheck [run?|clear?|cancel?]
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
  
  ```vimscript
  :RustLsp view [hir|mir]
  ```
  ```lua
  vim.cmd.RustLsp { 'view', 'hir' }
  vim.cmd.RustLsp { 'view', 'mir' }
  ```
</details>

<!-- markdownlint-restore -->

## Advanced configuration

To modify the default configuration, set `vim.g.rustaceanvim`.

- See [`:help rustaceanvim.config`](./doc/rustaceanvim.txt) for a detailed
  documentation of all available configuration options.
  You may need to run `:helptags ALL` if the documentation has not been installed.
- The default configuration [can be found here (see `RustaceanDefaultConfig`)](./lua/rustaceanvim/config/internal.lua).
- For detailed descriptions of the language server configs,
  see the [`rust-analyzer` documentation](https://rust-analyzer.github.io/manual.html#configuration).

The options shown below are the defaults.
You only need to pass the keys to the setup function
that you want to be changed, because the defaults
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
    settings = {
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

> [!NOTE]
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

By default, this plugin will look for a `rust-analyzer.json`
file in the project root directory, and attempt to load it.
If the file does not exist, or it can't be decoded,
the default settings will be used.

You can change this behaviour with the `server.settings` config:

```lua
vim.g.rustaceanvim = {
  -- ...
  server = {
    ---@param project_root string Path to the project root
    settings = function(project_root)
      local ra = require('rustaceanvim.config.server')
      return ra.load_rust_analyzer_settings(project_root, {
        settings_file_pattern = 'rust-analyzer.json'
      })
    end,
  },
}
```

## Troubleshooting

### Health checks

For a health check, run `:checkhealth rustaceanvim`

### `rust-analyzer` log file

To open the `rust-analyzer` log file, run `:RustLsp logFile`.

### Minimal config

To troubleshoot this plugin with a minimal config in a temporary directory,
you can try [minimal.lua](./troubleshooting/minimal.lua).

```console
mkdir -p /tmp/minimal/
NVIM_DATA_MINIMAL="/tmp/minimal" NVIM_APP_NAME="nvim-minimal" nvim -u minimal.lua
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

## FAQ

### Where are inlay hints?

As Neovim >= 0.10 supports inlay hints natively, I have removed the
code from this plugin.

To enable inlay hints in Neovim < 0.10, see [this discussion](https://github.com/mrcjkb/rustaceanvim/discussions/46#discussioncomment-7620822).

## Related Projects

- [`simrat39/rust-tools.nvim`](https://github.com/simrat39/rust-tools.nvim)
  This plugin is a heavily modified fork of `rust-tools.nvim`.
- [`Saecki/crates.nvim`](https://github.com/Saecki/crates.nvim)
- [`vxpm/ferris.nvim`](https://github.com/vxpm/ferris.nvim)
  Geared towards people who prefer manual LSP client configuration.
  Has some features that have not yet
  been implemented by this plugin.

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
