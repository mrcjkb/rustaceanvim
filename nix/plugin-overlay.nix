{
  self,
  name,
}: final: prev: let
  rustaceanvim-luaPackage-override = luaself: luaprev: {
    rustaceanvim = luaself.callPackage ({
      luaOlder,
      buildLuarocksPackage,
      lua,
    }:
      buildLuarocksPackage {
        pname = name;
        version = "scm-1";
        knownRockspec = "${self}/rustaceanvim-scm-1.rockspec";
        src = self;
        disabled = luaOlder "5.1";
      }) {};
  };

  lua5_1 = prev.lua5_1.override {
    packageOverrides = rustaceanvim-luaPackage-override;
  };

  lua51Packages = final.lua5_1.pkgs;
in {
  inherit
    lua5_1
    lua51Packages
    ;

  vimPlugins =
    prev.vimPlugins
    // {
      rustaceanvim = final.neovimUtils.buildNeovimPlugin {
        pname = name;
        version = "scm-1";
        src = self;
      };
    };

  rustaceanvim = final.vimPlugins.rustaceanvim;

  codelldb = final.vscode-extensions.vadimcn.vscode-lldb.adapter;
}
