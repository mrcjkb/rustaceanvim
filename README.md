<!-- markdownlint-disable -->
<br />
<div align="center">
  <a href="https://github.com/mrcjkb/ferris.nvim">
    <img src="./nvim-ferris.svg" alt="ferris.nvim">
  </a>
  <p align="center">
    <br />
    <a href="./doc/ferris.txt"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/mrcjkb/ferris.nvim/issues/new?assignees=&labels=bug&projects=&template=bug_report.yml">Report Bug</a>
    ·
    <a href="https://github.com/mrcjkb/ferris.nvim/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.yml">Request Feature</a>
    ·
    <a href="https://github.com/mrcjkb/ferris.nvim/discussions/new?category=q-a">Ask Question</a>
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

A heavily modified fork of [`rust-tools.nvim`](https://github.com/Saecki/crates.nvim).

## Quick Links

- [Installation](#installation)
- [Quick setup](#quick-setup)
- [Usage](#usage)
- [Advanced configuration](#advanced-configuration)

## Prerequisites

- `neovim 0.9`
- `rust-analyzer`
- `dot` from `graphviz` (optional), for crate graphs

## Installation

This plugin is [available on LuaRocks][luarocks-url].

If you use a plugin manager that does not support LuaRocks,
you have to declare the dependencies yourself.

Example using [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
{
  'mrcjkb/ferris.nvim',
  version = '^1', -- Recommended
  ft = { 'rust' },
}
```

>**Note**
>
>It is suggested to use the stable branch if you would like to avoid breaking changes.

To manually generate documentation, use `:helptags ALL`.

>**Note**
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

>**Warning**
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
  vim.cmd.RustCodeAction, 
  { silent = true, buffer = bufnr }
)
```

>**Note**
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
  
  ![debugging](https://github.com/simrat39/rust-tools-demos/raw/master/rust-tools-debug.gif)
</details>

<details>
  <summary>
	<b>Runnables</b>
  </summary>
  
  ![runnables](https://github.com/simrat39/rust-tools-demos/raw/master/runnables.gif)
  ```vimscript
  :RustRunnables
  ```
</details>

<details>
  <summary>
	<b>Expand Macros Recursively</b>
  </summary>
  
  ![expand macros](https://github.com/simrat39/rust-tools-demos/raw/master/expand_macros_recursively.gif)
  ```vimscript
  :RustExpandMacro  
  ```
</details>

<details>
  <summary>
	<b>Move Item Up/Down</b>
  </summary>
  
  ![move items](https://github.com/simrat39/rust-tools-demos/raw/master/move_item.gif)
  ```vimscript
  :RustMoveItemUp    
  :RustMoveItemDown    
```
</details>

<details>
  <summary>
	<b>Hover Actions</b>
  </summary>
  
 ![hover actions](https://github.com/simrat39/rust-tools-demos/raw/master/hover_actions.gif)
 Note: To activate hover actions, run the command twice. This will move you into the window, then press enter on the selection you want. Alternatively, you can set ```auto_focus``` to true in your config and you will automatically enter the hover actions window.
 ```vimscript
 :RustHoverActions 
 ```
</details>

<details>
  <summary>
	<b>Hover Range</b>
  </summary>

  ```vimscript
  :RustHoverRange 
  ```
</details>

<details>
  <summary>
	<b>Open Cargo.toml</b>
  </summary>
  
  ![open cargo](https://github.com/simrat39/rust-tools-demos/raw/master/open_cargo_toml.gif)
  ```vimscript
  :RustOpenCargo
  ```
</details>

<details>
  <summary>
	<b>Parent Module</b>
  </summary>
  
  ![parent module](https://github.com/simrat39/rust-tools-demos/raw/master/parent_module.gif)
  ```vimscript
  :RustParentModule 
  ```
</details>

<details>
  <summary>
	<b>Join Lines</b>
  </summary>
  
  ![join lines](https://github.com/simrat39/rust-tools-demos/raw/master/join_lines.gif)
  ```vimscript
  :RustJoinLines  
  ```
</details>

<details>
  <summary>
	<b>Structural Search Replace</b>
  </summary>
  
  ```vimscript
  :RustSSR [query]
  ```
</details>

<details>
  <summary>
	<b>View Crate Graph</b>
  </summary>
  
  ```vimscript
  :RustViewCrateGraph [backend [output]]
  ```
</details>

<details>
  <summary>
	<b>View Syntax Tree</b>
  </summary>
  
  ```vimscript
  :RustSyntaxTree
  ```
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
  :RustFlyCheck
  ```
</details>

<!-- markdownlint-restore -->

## Advanced configuration

To modify the default configuration, set `vim.g.ferris`.

- See [`:help ferris.config`](./doc/ferris.txt) for a detailed
  documentation of all available configuration options.
  You may need to run `:helptags ALL` if the documentation has not been installed.
- The default configuration [can be found here (see `FerrisDefaultConfig`)](./lua/ferris/config/internal.lua).
- For detailed descriptions of the language server configs,
  see the [`rust-analyzer` documentation](https://rust-analyzer.github.io/manual.html#configuration).

The options shown below are the defaults.
You only need to pass the keys to the setup function
that you want to be changed, because the defaults
are applied for keys that are not provided.

Example config:

```lua
vim.g.ferris = {
  -- Plugin configuration
  tools = {
  },
  -- LSP configuration
  server = {
    on_attach = function(client, bufnr)
      -- you can also put keymaps in here
    end,
    -- rust-analyzer language server configuration
    ['rust-analyzer'] = {
    },
  },
  -- DAP configuration
  dap = {
  },
}
```

> **Note**
>
> `vim.g.ferris` can also be a function that returns
> a table.

## Related Projects

- [`simrat39/rust-tools.nvim`](https://github.com/simrat39/rust-tools.nvim)
  This plugin is a heavily modified fork of `rust-tools.nvim`.
- [`Saecki/crates.nvim`](https://github.com/Saecki/crates.nvim)

## Inspiration

This plugin draws inspiration from [`akinsho/flutter-tools.nvim`](https://github.com/akinsho/flutter-tools.nvim)

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
[issues-shield]: https://img.shields.io/github/issues/mrcjkb/ferris.nvim.svg?style=for-the-badge
[issues-url]: https://github.com/mrcjkb/ferris.nvim/issues
[license-shield]: https://img.shields.io/github/license/mrcjkb/ferris.nvim.svg?style=for-the-badge
[license-url]: https://github.com/mrcjkb/ferris.nvim/blob/master/LICENSE
[ci-shield]: https://img.shields.io/github/actions/workflow/status/mrcjkb/ferris.nvim/nix-build.yml?style=for-the-badge
[ci-url]: https://github.com/mrcjkb/ferris.nvim/actions/workflows/nix-build.yml
[luarocks-shield]: https://img.shields.io/luarocks/v/MrcJkb/ferris.nvim?logo=lua&color=purple&style=for-the-badge
[luarocks-url]: https://luarocks.org/modules/MrcJkb/ferris.nvim
