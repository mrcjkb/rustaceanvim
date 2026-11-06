# Add flake.nix test inputs as arguments here
{neovim-nightly}: final: prev: let
  inherit (final) lib;

  # For manual debugging purposes
  mkNvimMinimal = nvim:
    with final; let
      runtimeDeps = [
        rust-analyzer
        cargo
        rustc
        lldb
      ];
    in
      final.wrapNeovimUnstable nvim {
        withPython3 = true;
        viAlias = true;
        vimAlias = true;
        plugins = with vimPlugins; [
          rustaceanvim
          prev.vimPlugins.nvim-treesitter.withAllGrammars
        ];
        wrapperArgs =
          ''--set NVIM_APPNAME "nvim-rustaceanvim" ''
          + ''--prefix PATH : "${lib.makeBinPath runtimeDeps}"'';
        neovimRcContent = ''
          lua << EOF
          -- set config here
          -- vim.g.rustaceanvim = {}
          EOF
        '';
      };
in {
  nvim-minimal-stable = mkNvimMinimal final.neovim-unwrapped;
  nvim-minimal-nightly = mkNvimMinimal neovim-nightly;
}
