# Add flake.nix test inputs as arguments here
{
  self,
  plugin-name,
}: final: prev: let
  nvim-nightly = final.neovim-nightly;

  lib = final.lib;

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

  mkNeorocksTest = {
    name,
    nvim ? final.neovim-unwrapped,
    extraPkgs ? [],
  }: let
    nvim-wrapped = final.pkgs.wrapNeovim nvim {
      configure = {
        packages.myVimPackage = {
          start = [
            # Add plugin dependencies that aren't on LuaRocks here
          ];
        };
      };
    };
  in
    final.pkgs.neorocksTest {
      inherit name;
      pname = plugin-name;
      src = self;
      neovim = nvim-wrapped;

      # luaPackages = ps: with ps; [];
      extraPackages = with final; [
        rust-analyzer
        cargo
      ];

      preCheck = ''
        export HOME=$(realpath .)
      '';

      buildPhase = ''
        mkdir -p $out
        cp -r tests $out
      '';
    };
in {
  nvim-stable-tests = mkNeorocksTest {name = "neovim-stable-tests";};
  nvim-nightly-tests = mkNeorocksTest {
    name = "neovim-nightly-tests";
    nvim = nvim-nightly;
  };
  nvim-minimal-stable = mkNvimMinimal final.neovim-unwrapped;
  nvim-minimal-nightly = mkNvimMinimal nvim-nightly;
}
