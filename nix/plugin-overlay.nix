{
  name,
  self,
}: final: prev: {
  ferris-nvim = final.pkgs.vimUtils.buildVimPlugin {
    inherit name;
    src = self;
  };
}
