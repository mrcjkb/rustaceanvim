{
  pkgs,
  vimcats,
  ...
}:
pkgs.writeShellApplication {
  name = "docgen";
  runtimeInputs = [
    vimcats.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  text = ''
    mkdir -p doc
    vimcats lua/rustaceanvim/{init,config/init,config/server,neotest/init,dap}.lua > doc/rustaceanvim.txt
  '';
}
