---@toc ferris.contents

---@mod intro Introduction
---@brief [[
---This plugin automatically configures the `rust-analyzer` builtin LSP client
---and integrates with other rust tools.
---@brief ]]
---
---@mod ferris
---
---@brief [[
---Commands:
---
--- `:RustRunnables` - Run tests, etc.
--- `:RustExpandMacro` - Expand macros recursively.
--- `:RustMoveItemUp`, `:RustMoveItemDown` - Move items up or down
--- `:RustHoverRange` - Hover over visually selected range.
--- `:RustOpenCargo` - Open the Cargo.toml file for the current package.
--- `:RustParentModule` - Open the current module's parent module.
--- `:RustJoinLines` - Join adjacent lines.
--- `:RustSSR [query]` - Structural search and replace.
--- `:RustViewCrateGraph` - Create and view a crate graph with graphviz.
--- `:RustSyntaxTree` - View the syntax tree.
--- `:RustFlyCheck` - Run `cargo check` or another compatible command (f.x. `clippy`)
---                   in a background thread and provide LSP diagnostics based on
---                   the output of the command.
---                   Useful in large projects where running `cargo check` on each save
---                   can be costly.
---@brief ]]

local M = {}
return M
