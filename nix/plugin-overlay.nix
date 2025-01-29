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
  luajit = prev.luajit.override {
    packageOverrides = rustaceanvim-luaPackage-override;
  };

  lua51Packages = final.lua5_1.pkgs;
  luajitPackages = final.luajit.pkgs;
in {
  inherit
    lua5_1
    lua51Packages
    luajit
    luajitPackages
    ;

  vimPlugins =
    prev.vimPlugins
    // {
      rustaceanvim = final.neovimUtils.buildNeovimPlugin {
        luaAttr = final.luajitPackages.rustaceanvim;
      };
    };

  rustaceanvim = final.vimPlugins.rustaceanvim;
  rustaceanvim-dev = final.vimPlugins.rustaceanvim;

  codelldb = final.vscode-extensions.vadimcn.vscode-lldb.adapter;
}
