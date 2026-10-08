{
  lib,
  config,
  myConfig,
  self,
  ...
}:
let
  mkLinks = import ../../../home/mk-links.nix {
    inherit
      lib
      config
      myConfig
      self
      ;
    homePath = myConfig.hostHomePath;
    basePath = myConfig.basePath;
  };
in
{
  xdg.stateFile = mkLinks "" [
    { "noctalia/settings.toml" = "noctalia.toml"; }
  ];
}
