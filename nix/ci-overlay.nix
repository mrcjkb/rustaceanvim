# Add flake.nix test inputs as arguments here
final: prev: let
  nvim-nightly = final.neovim-nightly;

  inherit (final) lib;

  # For manual debugging purposes
  mkNvimMinimal = nvim:
    with final; let
      neovimConfig = neovimUtils.makeNeovimConfig {
        withPython3 = true;
        viAlias = true;
        vimAlias = true;
        plugins = with vimPlugins; [
          # Add plugins here
          rustaceanvim
          prev.vimPlugins.nvim-treesitter.withAllGrammars
        ];
      };
      runtimeDeps = [
        rust-analyzer
        cargo
        rustc
        lldb
      ];
    in
      final.wrapNeovimUnstable nvim (neovimConfig
        // {
          wrapperArgs =
            lib.escapeShellArgs neovimConfig.wrapperArgs
            + " "
            + ''--set NVIM_APPNAME "nvim-rustaceanvim"''
            + " "
            + ''--prefix PATH : "${lib.makeBinPath runtimeDeps}"'';
          wrapRc = true;
          neovimRcContent = ''
            lua << EOF
            -- set config here
            -- vim.g.rustaceanvim = {}
            EOF
          '';
        });

in {
  nvim-minimal-stable = mkNvimMinimal final.neovim-unwrapped;
  nvim-minimal-nightly = mkNvimMinimal nvim-nightly;
}
