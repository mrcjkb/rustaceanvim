<!-- markdownlint-disable -->

**Possible rust-analyzer settings (rust-analyzer 0.0.0 (634cfe3d7 2022-08-07))**  
```lua
-- example opts  
local opts = {  
  -- other configurations  
  server = {
    settings = {
      ['rust-analyzer'] {
        cargo = {
          autoReload = true
        }
      }
    }
  }
}
```

---
**`rust-analyzer.assist.expressionFillDefault`**: `string`,   
**Default**: `todo`  
**Description**: Placeholder expression to use for missing expressions in assists.  
**Possible Values**
- **todo**: Fill missing expressions with the `todo` macro
- **default**: Fill missing expressions with reasonable defaults, `new` or `default` constructors.

---
**`rust-analyzer.cachePriming.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Warm up caches on project load.  

---
**`rust-analyzer.cachePriming.numThreads`**: `number`,   
**Default**: `0`  
**Description**: How many worker threads to handle priming caches. The default `0` means to pick automatically.  

---
**`rust-analyzer.cargo.autoreload`**: `boolean`,   
**Default**: `true`  
**Description**: Automatically refresh project info via `cargo metadata` on
`Cargo.toml` or `.cargo/config.toml` changes.  

---
**`rust-analyzer.cargo.buildScripts.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Run build scripts (`build.rs`) for more precise code analysis.  

---
**`rust-analyzer.cargo.buildScripts.overrideCommand`**: `null`, `array`,   
**Default**: `null`  
**Description**: Override the command rust-analyzer uses to run build scripts and
build procedural macros. The command is required to output json
and should therefore include `--message-format=json` or a similar
option.

By default, a cargo invocation will be constructed for the configured
targets and features, with the following base command line:

```bash
cargo check --quiet --workspace --message-format=json --all-targets
```
.  

---
**`rust-analyzer.cargo.buildScripts.useRustcWrapper`**: `boolean`,   
**Default**: `true`  
**Description**: Use `RUSTC_WRAPPER=rust-analyzer` when running build scripts to
avoid checking unnecessary things.  

---
**`rust-analyzer.cargo.features`**: `null`,   
**Default**: `[]`  
**Description**: List of features to activate.

Set this to `"all"` to pass `--all-features` to cargo.  

---
**`rust-analyzer.cargo.noDefaultFeatures`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to pass `--no-default-features` to cargo.  

---
**`rust-analyzer.cargo.noSysroot`**: `boolean`,   
**Default**: `false`  
**Description**: Internal config for debugging, disables loading of sysroot crates.  

---
**`rust-analyzer.cargo.target`**: `null`, `string`,   
**Default**: `null`  
**Description**: Compilation target override (target triple).  

---
**`rust-analyzer.cargo.unsetTest`**: `array`,   
**Default**: `[core]`  
**Description**: Unsets `#[cfg(test)]` for the specified crates.  

---
**`rust-analyzer.checkOnSave.allTargets`**: `boolean`,   
**Default**: `true`  
**Description**: Check all targets and tests (`--all-targets`).  

---
**`rust-analyzer.checkOnSave.command`**: `string`,   
**Default**: `check`  
**Description**: Cargo command to use for `cargo check`.  

---
**`rust-analyzer.checkOnSave.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Run specified `cargo check` command for diagnostics on save.  

---
**`rust-analyzer.checkOnSave.extraArgs`**: `array`,   
**Default**: `[]`  
**Description**: Extra arguments for `cargo check`.  

---
**`rust-analyzer.checkOnSave.features`**: `null`,   
**Default**: `null`  
**Description**: List of features to activate. Defaults to
`#rust-analyzer.cargo.features#`.

Set to `"all"` to pass `--all-features` to Cargo.  

---
**`rust-analyzer.checkOnSave.noDefaultFeatures`**: `null`, `boolean`,   
**Default**: `null`  
**Description**: Whether to pass `--no-default-features` to Cargo. Defaults to
`#rust-analyzer.cargo.noDefaultFeatures#`.  

---
**`rust-analyzer.checkOnSave.overrideCommand`**: `null`, `array`,   
**Default**: `null`  
**Description**: Override the command rust-analyzer uses instead of `cargo check` for
diagnostics on save. The command is required to output json and
should therefor include `--message-format=json` or a similar option.

If you're changing this because you're using some tool wrapping
Cargo, you might also want to change
`#rust-analyzer.cargo.buildScripts.overrideCommand#`.

An example command would be:

```bash
cargo check --workspace --message-format=json --all-targets
```
.  

---
**`rust-analyzer.checkOnSave.target`**: `null`, `string`,   
**Default**: `null`  
**Description**: Check for a specific target. Defaults to
`#rust-analyzer.cargo.target#`.  

---
**`rust-analyzer.completion.autoimport.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Toggles the additional completions that automatically add imports when completed.
Note that your client must specify the `additionalTextEdits` LSP client capability to truly have this feature enabled.  

---
**`rust-analyzer.completion.autoself.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Toggles the additional completions that automatically show method calls and field accesses
with `self` prefixed to them when inside a method.  

---
**`rust-analyzer.completion.callable.snippets`**: `string`,   
**Default**: `fill_arguments`  
**Description**: Whether to add parenthesis and argument snippets when completing function.  
**Possible Values**
- **fill_arguments**: Add call parentheses and pre-fill arguments.
- **add_parentheses**: Add call parentheses.
- **none**: Do no snippet completions for callables.

---
**`rust-analyzer.completion.postfix.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show postfix snippets like `dbg`, `if`, `not`, etc.  

---
**`rust-analyzer.completion.privateEditable.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Enables completions of private items and fields that are defined in the current workspace even if they are not visible at the current position.  

---
**`rust-analyzer.completion.snippets.custom`**: `object`,   
**Default**: `{Arc::new: {postfix: arc, body: Arc::new(${receiver}), requires: std::sync::Arc, description: Put the expression into an `Arc`, scope: expr}, Rc::new: {postfix: rc, body: Rc::new(${receiver}), requires: std::rc::Rc, description: Put the expression into an `Rc`, scope: expr}, Box::pin: {postfix: pinbox, body: Box::pin(${receiver}), requires: std::boxed::Box, description: Put the expression into a pinned `Box`, scope: expr}, Ok: {postfix: ok, body: Ok(${receiver}), description: Wrap the expression in a `Result::Ok`, scope: expr}, Err: {postfix: err, body: Err(${receiver}), description: Wrap the expression in a `Result::Err`, scope: expr}, Some: {postfix: some, body: Some(${receiver}), description: Wrap the expression in an `Option::Some`, scope: expr}}`  
**Description**: Custom completion snippets.  

---
**`rust-analyzer.diagnostics.disabled`**: `array`,   
**Default**: `[]`  
**Description**: List of rust-analyzer diagnostics to disable.  

---
**`rust-analyzer.diagnostics.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show native rust-analyzer diagnostics.  

---
**`rust-analyzer.diagnostics.experimental.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to show experimental rust-analyzer diagnostics that might
have more false positives than usual.  

---
**`rust-analyzer.diagnostics.remapPrefix`**: `object`,   
**Default**: `{}`  
**Description**: Map of prefixes to be substituted when parsing diagnostic file paths.
This should be the reverse mapping of what is passed to `rustc` as `--remap-path-prefix`.  

---
**`rust-analyzer.diagnostics.warningsAsHint`**: `array`,   
**Default**: `[]`  
**Description**: List of warnings that should be displayed with hint severity.

The warnings will be indicated by faded text or three dots in code
and will not show up in the `Problems Panel`.  

---
**`rust-analyzer.diagnostics.warningsAsInfo`**: `array`,   
**Default**: `[]`  
**Description**: List of warnings that should be displayed with info severity.

The warnings will be indicated by a blue squiggly underline in code
and a blue icon in the `Problems Panel`.  

---
**`rust-analyzer.files.excludeDirs`**: `array`,   
**Default**: `[]`  
**Description**: These directories will be ignored by rust-analyzer. They are
relative to the workspace root, and globs are not supported. You may
also need to add the folders to Code's `files.watcherExclude`.  

---
**`rust-analyzer.files.watcher`**: `string`,   
**Default**: `client`  
**Description**: Controls file watching implementation.  
**Possible Values**
- **client**: Use the client (editor) to watch files for changes
- **server**: Use server-side file watching

---
**`rust-analyzer.highlightRelated.breakPoints.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Enables highlighting of related references while the cursor is on `break`, `loop`, `while`, or `for` keywords.  

---
**`rust-analyzer.highlightRelated.exitPoints.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Enables highlighting of all exit points while the cursor is on any `return`, `?`, `fn`, or return type arrow (`->`).  

---
**`rust-analyzer.highlightRelated.references.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Enables highlighting of related references while the cursor is on any identifier.  

---
**`rust-analyzer.highlightRelated.yieldPoints.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Enables highlighting of all break points for a loop or block context while the cursor is on any `async` or `await` keywords.  

---
**`rust-analyzer.hover.actions.debug.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show `Debug` action. Only applies when
`#rust-analyzer.hover.actions.enable#` is set.  

---
**`rust-analyzer.hover.actions.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show HoverActions in Rust files.  

---
**`rust-analyzer.hover.actions.gotoTypeDef.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show `Go to Type Definition` action. Only applies when
`#rust-analyzer.hover.actions.enable#` is set.  

---
**`rust-analyzer.hover.actions.implementations.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show `Implementations` action. Only applies when
`#rust-analyzer.hover.actions.enable#` is set.  

---
**`rust-analyzer.hover.actions.references.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to show `References` action. Only applies when
`#rust-analyzer.hover.actions.enable#` is set.  

---
**`rust-analyzer.hover.actions.run.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show `Run` action. Only applies when
`#rust-analyzer.hover.actions.enable#` is set.  

---
**`rust-analyzer.hover.documentation.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show documentation on hover.  

---
**`rust-analyzer.hover.links.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Use markdown syntax for links in hover.  

---
**`rust-analyzer.imports.granularity.enforce`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to enforce the import granularity setting for all files. If set to false rust-analyzer will try to keep import styles consistent per file.  

---
**`rust-analyzer.imports.granularity.group`**: `string`,   
**Default**: `crate`  
**Description**: How imports should be grouped into use statements.  
**Possible Values**
- **preserve**: Do not change the granularity of any imports and preserve the original structure written by the developer.
- **crate**: Merge imports from the same crate into a single use statement. Conversely, imports from different crates are split into separate statements.
- **module**: Merge imports from the same module into a single use statement. Conversely, imports from different modules are split into separate statements.
- **item**: Flatten imports so that each has its own use statement.

---
**`rust-analyzer.imports.group.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Group inserted imports by the https://rust-analyzer.github.io/manual.html#auto-import[following order]. Groups are separated by newlines.  

---
**`rust-analyzer.imports.merge.glob`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to allow import insertion to merge new imports into single path glob imports like `use std::fmt::*;`.  

---
**`rust-analyzer.imports.prefix`**: `string`,   
**Default**: `plain`  
**Description**: The path structure for newly inserted paths to use.  
**Possible Values**
- **plain**: Insert import paths relative to the current module, using up to one `super` prefix if the parent module contains the requested item.
- **self**: Insert import paths relative to the current module, using up to one `super` prefix if the parent module contains the requested item. Prefixes `self` in front of the path if it starts with a module.
- **crate**: Force import paths to be absolute by always starting them with `crate` or the extern crate name they come from.

---
**`rust-analyzer.inlayHints.bindingModeHints.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to show inlay type hints for binding modes.  

---
**`rust-analyzer.inlayHints.chainingHints.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show inlay type hints for method chains.  

---
**`rust-analyzer.inlayHints.closingBraceHints.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show inlay hints after a closing `}` to indicate what item it belongs to.  

---
**`rust-analyzer.inlayHints.closingBraceHints.minLines`**: `integer`,   
**Default**: `25`  
**Description**: Minimum number of lines required before the `}` until the hint is shown (set to 0 or 1
to always show them).  

---
**`rust-analyzer.inlayHints.closureReturnTypeHints.enable`**: `string`,   
**Default**: `never`  
**Description**: Whether to show inlay type hints for return types of closures.  
**Possible Values**
- **always**: Always show type hints for return types of closures.
- **never**: Never show type hints for return types of closures.
- **with_block**: Only show type hints for return types of closures with blocks.

---
**`rust-analyzer.inlayHints.lifetimeElisionHints.enable`**: `string`,   
**Default**: `never`  
**Description**: Whether to show inlay type hints for elided lifetimes in function signatures.  
**Possible Values**
- **always**: Always show lifetime elision hints.
- **never**: Never show lifetime elision hints.
- **skip_trivial**: Only show lifetime elision hints if a return type is involved.

---
**`rust-analyzer.inlayHints.lifetimeElisionHints.useParameterNames`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to prefer using parameter names as the name for elided lifetime hints if possible.  

---
**`rust-analyzer.inlayHints.maxLength`**: `null`, `integer`,   
**Default**: `25`  
**Description**: Maximum length for inlay hints. Set to null to have an unlimited length.  

---
**`rust-analyzer.inlayHints.parameterHints.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show function parameter name inlay hints at the call
site.  

---
**`rust-analyzer.inlayHints.reborrowHints.enable`**: `string`,   
**Default**: `never`  
**Description**: Whether to show inlay type hints for compiler inserted reborrows.  
**Possible Values**
- **always**: Always show reborrow hints.
- **never**: Never show reborrow hints.
- **mutable**: Only show mutable reborrow hints.

---
**`rust-analyzer.inlayHints.renderColons`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to render leading colons for type hints, and trailing colons for parameter hints.  

---
**`rust-analyzer.inlayHints.typeHints.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show inlay type hints for variables.  

---
**`rust-analyzer.inlayHints.typeHints.hideClosureInitialization`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to hide inlay type hints for `let` statements that initialize to a closure.
Only applies to closures with blocks, same as `#rust-analyzer.inlayHints.closureReturnTypeHints.enable#`.  

---
**`rust-analyzer.inlayHints.typeHints.hideNamedConstructor`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to hide inlay type hints for constructors.  

---
**`rust-analyzer.joinLines.joinAssignments`**: `boolean`,   
**Default**: `true`  
**Description**: Join lines merges consecutive declaration and initialization of an assignment.  

---
**`rust-analyzer.joinLines.joinElseIf`**: `boolean`,   
**Default**: `true`  
**Description**: Join lines inserts else between consecutive ifs.  

---
**`rust-analyzer.joinLines.removeTrailingComma`**: `boolean`,   
**Default**: `true`  
**Description**: Join lines removes trailing commas.  

---
**`rust-analyzer.joinLines.unwrapTrivialBlock`**: `boolean`,   
**Default**: `true`  
**Description**: Join lines unwraps trivial blocks.  

---
**`rust-analyzer.lens.debug.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show `Debug` lens. Only applies when
`#rust-analyzer.lens.enable#` is set.  

---
**`rust-analyzer.lens.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show CodeLens in Rust files.  

---
**`rust-analyzer.lens.forceCustomCommands`**: `boolean`,   
**Default**: `true`  
**Description**: Internal config: use custom client-side commands even when the
client doesn't set the corresponding capability.  

---
**`rust-analyzer.lens.implementations.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show `Implementations` lens. Only applies when
`#rust-analyzer.lens.enable#` is set.  

---
**`rust-analyzer.lens.references.adt.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to show `References` lens for Struct, Enum, and Union.
Only applies when `#rust-analyzer.lens.enable#` is set.  

---
**`rust-analyzer.lens.references.enumVariant.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to show `References` lens for Enum Variants.
Only applies when `#rust-analyzer.lens.enable#` is set.  

---
**`rust-analyzer.lens.references.method.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to show `Method References` lens. Only applies when
`#rust-analyzer.lens.enable#` is set.  

---
**`rust-analyzer.lens.references.trait.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to show `References` lens for Trait.
Only applies when `#rust-analyzer.lens.enable#` is set.  

---
**`rust-analyzer.lens.run.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show `Run` lens. Only applies when
`#rust-analyzer.lens.enable#` is set.  

---
**`rust-analyzer.linkedProjects`**: `array`,   
**Default**: `[]`  
**Description**: Disable project auto-discovery in favor of explicitly specified set
of projects.

Elements must be paths pointing to `Cargo.toml`,
`rust-project.json`, or JSON objects in `rust-project.json` format.  

---
**`rust-analyzer.lru.capacity`**: `null`, `integer`,   
**Default**: `null`  
**Description**: Number of syntax trees rust-analyzer keeps in memory. Defaults to 128.  

---
**`rust-analyzer.notifications.cargoTomlNotFound`**: `boolean`,   
**Default**: `true`  
**Description**: Whether to show `can't find Cargo.toml` error message.  

---
**`rust-analyzer.procMacro.attributes.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Expand attribute macros. Requires `#rust-analyzer.procMacro.enable#` to be set.  

---
**`rust-analyzer.procMacro.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Enable support for procedural macros, implies `#rust-analyzer.cargo.buildScripts.enable#`.  

---
**`rust-analyzer.procMacro.ignored`**: `object`,   
**Default**: `{}`  
**Description**: These proc-macros will be ignored when trying to expand them.

This config takes a map of crate names with the exported proc-macro names to ignore as values.  

---
**`rust-analyzer.procMacro.server`**: `null`, `string`,   
**Default**: `null`  
**Description**: Internal config, path to proc-macro server executable (typically,
this is rust-analyzer itself, but we override this in tests).  

---
**`rust-analyzer.runnables.command`**: `null`, `string`,   
**Default**: `null`  
**Description**: Command to be executed instead of 'cargo' for runnables.  

---
**`rust-analyzer.runnables.extraArgs`**: `array`,   
**Default**: `[]`  
**Description**: Additional arguments to be passed to cargo for runnables such as
tests or binaries. For example, it may be `--release`.  

---
**`rust-analyzer.rustc.source`**: `null`, `string`,   
**Default**: `null`  
**Description**: Path to the Cargo.toml of the rust compiler workspace, for usage in rustc_private
projects, or "discover" to try to automatically find it if the `rustc-dev` component
is installed.

Any project which uses rust-analyzer with the rustcPrivate
crates must set `[package.metadata.rust-analyzer] rustc_private=true` to use it.

This option does not take effect until rust-analyzer is restarted.  

---
**`rust-analyzer.rustfmt.extraArgs`**: `array`,   
**Default**: `[]`  
**Description**: Additional arguments to `rustfmt`.  

---
**`rust-analyzer.rustfmt.overrideCommand`**: `null`, `array`,   
**Default**: `null`  
**Description**: Advanced option, fully override the command rust-analyzer uses for
formatting.  

---
**`rust-analyzer.rustfmt.rangeFormatting.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Enables the use of rustfmt's unstable range formatting command for the
`textDocument/rangeFormatting` request. The rustfmt option is unstable and only
available on a nightly build.  

---
**`rust-analyzer.semanticHighlighting.strings.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Use semantic tokens for strings.

In some editors (e.g. vscode) semantic tokens override other highlighting grammars.
By disabling semantic tokens for strings, other grammars can be used to highlight
their contents.  

---
**`rust-analyzer.signatureInfo.detail`**: `string`,   
**Default**: `full`  
**Description**: Show full signature of the callable. Only shows parameters if disabled.  
**Possible Values**
- **full**: Show the entire signature.
- **parameters**: Show only the parameters.

---
**`rust-analyzer.signatureInfo.documentation.enable`**: `boolean`,   
**Default**: `true`  
**Description**: Show documentation.  

---
**`rust-analyzer.typing.autoClosingAngleBrackets.enable`**: `boolean`,   
**Default**: `false`  
**Description**: Whether to insert closing angle brackets when typing an opening angle bracket of a generic argument list.  

---
**`rust-analyzer.workspace.symbol.search.kind`**: `string`,   
**Default**: `only_types`  
**Description**: Workspace symbol search kind.  
**Possible Values**
- **only_types**: Search for types only.
- **all_symbols**: Search for all symbols kinds.

---
**`rust-analyzer.workspace.symbol.search.limit`**: `integer`,   
**Default**: `128`  
**Description**: Limits the number of items returned from a workspace symbol search (Defaults to 128).
Some clients like vs-code issue new searches on result filtering and don't require all results to be returned in the initial search.
Other clients requires all results upfront and might require a higher limit.  

---
**`rust-analyzer.workspace.symbol.search.scope`**: `string`,   
**Default**: `workspace`  
**Description**: Workspace symbol search scope.  
**Possible Values**
- **workspace**: Search in current workspace only.
- **workspace_and_dependencies**: Search in current workspace and dependencies.

---
