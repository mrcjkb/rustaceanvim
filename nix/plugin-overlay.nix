{
  name,
  self,
}: final: prev: {
  rustaceanvim-nvim = final.pkgs.vimUtils.buildVimPlugin {
    inherit name;
    src = self;
  };
}
