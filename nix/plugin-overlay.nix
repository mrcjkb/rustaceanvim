{
  name,
  self,
}: final: prev: {
  rustaceanvim = final.pkgs.vimUtils.buildVimPlugin {
    inherit name;
    src = self;
  };
}
