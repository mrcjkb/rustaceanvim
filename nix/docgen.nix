{pkgs, ...}:
pkgs.writeShellApplication {
  name = "docgen";
  runtimeInputs = with pkgs; [
    lemmy-help
  ];
  text = ''
    mkdir -p doc
    lemmy-help lua/rustaceanvim/{init,config/init,config/server,neotest/init,dap}.lua > doc/rustaceanvim.txt
  '';
}
